using System.Text;
using System.Text.Json;
using System.Threading.RateLimiting;
using HappyviewProxy.Services;


var builder = WebApplication.CreateBuilder(args);

builder.Services.AddMemoryCache();

// 1. Register HttpClient so we can make external web requests.
// Pixabay requests are routed through a shared service that adds 24h caching, request coalescing,
// and an internal rate limiter so the public API isn't throttled when duplicates are absorbed by cache.
builder.Services.AddHttpClient();
builder.Services.AddHttpClient<PixabayProxyService>((sp, client) =>
{
    var baseUrl = sp.GetRequiredService<IConfiguration>().GetValue<string>("Pixabay:BaseUrl") ?? "https://pixabay.com/api/";
    client.BaseAddress = new Uri(baseUrl);
});

const string PixabayRateLimiterName = "pixabay-internal";
const string SuggestionsRateLimiterPolicy = "suggestions";

builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.AddPolicy(SuggestionsRateLimiterPolicy, httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                Window = TimeSpan.FromMinutes(1),
                PermitLimit = 3,
                QueueLimit = 0,
            }));

    options.AddPolicy(PixabayRateLimiterName, _ =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: "pixabay",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                Window = TimeSpan.FromSeconds(60),
                PermitLimit = 90,
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 25,
            }));
});

builder.Services.AddSingleton(new FixedWindowRateLimiter(new FixedWindowRateLimiterOptions
{
    Window = TimeSpan.FromSeconds(60),
    PermitLimit = 90,
    QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
    QueueLimit = 25,
}));

var app = builder.Build();

app.UseRateLimiter();

if (app.Environment.IsProduction())
{
    app.UseHsts();
}

app.UseHttpsRedirection();
////////////////////////////////////////////
/// 
/// 
/// 
// 2. Define the proxy endpoint
app.MapGet("/api/search", async (
    string query,
    string lang,
    PixabayProxyService pixabayProxyService) =>
{
    if (string.IsNullOrWhiteSpace(query))
    {
        return Results.BadRequest("Search query cannot be empty.");
    }

    try
    {
        var images = await pixabayProxyService.GetImagesAsync(query, category: null, page: 1, perPage: 20, safesearch: true);

        return Results.Ok(images.Select(image => new
        {
            Id = image.Id,
            PreviewUrl = image.Url,
            LargeUrl = image.LargeUrl,
            Tags = image.Title
        }));
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error fetching from Pixabay: {ex.Message}");
        return Results.StatusCode(500);
    }
});

// 3. Category-browsing / general image proxy endpoint (replaces the client's former direct Pixabay calls)
app.MapGet("/api/images", async (
    string q,
    PixabayProxyService pixabayProxyService,
    int page = 1,
    int perPage = 20,
    string? category = null,
    bool safesearch = true) =>
{
    if (string.IsNullOrWhiteSpace(q))
    {
        return Results.BadRequest("Query cannot be empty.");
    }

    var pageNumber = page < 1 ? 1 : page;
    var pageSize = perPage is < 1 or > 50 ? 20 : perPage;

    try
    {
        var images = await pixabayProxyService.GetImagesAsync(q, category, pageNumber, pageSize, safesearch);
        return Results.Ok(images);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error fetching from Pixabay: {ex.Message}");
        return Results.StatusCode(500);
    }
});

// 4. Translate search queries (replaces the client's former direct Google Translate calls)
app.MapGet("/api/translate", async (
    string q,
    IHttpClientFactory httpClientFactory,
    string to = "en") =>
{
    if (string.IsNullOrWhiteSpace(q))
    {
        return Results.BadRequest("Text cannot be empty.");
    }

    // This is a search query, not a document — cap it defensively
    var text = q.Length > 200 ? q[..200] : q;

    var requestUrl = "https://translate.googleapis.com/translate_a/single" +
        $"?client=gtx&sl=auto&tl={Uri.EscapeDataString(to)}&dt=t&q={Uri.EscapeDataString(text)}";

    try
    {
        var client = httpClientFactory.CreateClient();
        var response = await client.GetAsync(requestUrl);

        if (!response.IsSuccessStatusCode)
        {
            return Results.StatusCode((int)response.StatusCode);
        }

        var jsonResponse = await response.Content.ReadAsStringAsync();
        using var document = JsonDocument.Parse(jsonResponse);

        // Response shape: [[[translatedChunk, originalChunk, ...], ...], ...]
        var sb = new StringBuilder();
        foreach (var sentence in document.RootElement[0].EnumerateArray())
        {
            sb.Append(sentence[0].GetString());
        }

        return Results.Ok(new { translatedText = sb.ToString() });
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error translating text: {ex.Message}");
        return Results.StatusCode(500);
    }
});

// 5. Suggestion form relay — forwards a parent-gated suggestion to a private Telegram chat.
// Stateless: nothing is persisted here, and content/email are never written to logs.
app.MapPost("/api/suggestions", async (
    SuggestionRequest request,
    IConfiguration config,
    IHttpClientFactory httpClientFactory) =>
    {
    var content = request.Content?.Trim() ?? string.Empty;
    if (content.Length is < 1 or > 200)
    {
        return Results.BadRequest("Content must be between 1 and 200 characters.");
    }

    var email = request.Email?.Trim();
    if (!string.IsNullOrEmpty(email) && email.Length > 200)
    {
        return Results.BadRequest("Email is too long.");
    }

    var category = request.Category?.Trim();
    if (!string.IsNullOrEmpty(category) && category.Length > 100)
    {
        return Results.BadRequest("Category is too long.");
    }

    var botToken = config["Telegram:BotToken"];
    var chatId = config["Telegram:ChatId"];

    if (string.IsNullOrEmpty(botToken) || string.IsNullOrEmpty(chatId))
    {
        Console.WriteLine("Suggestion relay is not configured (missing Telegram bot token/chat id).");
        return Results.StatusCode(500);
    }

    // Build a plain-text message; Telegram messages are capped well above what we accept here
    var message = new StringBuilder("New suggestion submitted:\n\n").Append(content);
    if (!string.IsNullOrEmpty(category))
    {
        message.Append("\n\nCategory: ").Append(category);
    }
    if (!string.IsNullOrEmpty(email))
    {
        message.Append("\nContact email: ").Append(email);
    }

    try
    {
        var client = httpClientFactory.CreateClient();
        var telegramUrl = $"https://api.telegram.org/bot{botToken}/sendMessage";

        var response = await client.PostAsJsonAsync(telegramUrl, new
        {
            chat_id = chatId,
            text = message.ToString(),
        });

        if (!response.IsSuccessStatusCode)
        {
            // Don't log the response body — it echoes back our request, including the message text
            Console.WriteLine($"Telegram relay failed with status {(int)response.StatusCode}.");
            return Results.StatusCode(502);
        }

        return Results.Ok(new { success = true });
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error relaying suggestion to Telegram: {ex.GetType().Name}");
        return Results.StatusCode(500);
    }
})

.RequireRateLimiting(SuggestionsRateLimiterPolicy);

app.Run();

record SuggestionRequest(string? Content, string? Email, string? Category);