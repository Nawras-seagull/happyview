using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

// 1. Register HttpClient so we can make external web requests
builder.Services.AddHttpClient();

// Cap /api/suggestions submissions per client IP so one abusive client can't spam
// the Telegram bot (or block other users) via a decompiled client.
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
});

var app = builder.Build();

app.UseRateLimiter();

if (app.Environment.IsProduction())
{
    app.UseHsts();
}

app.UseHttpsRedirection();

// 2. Define the proxy endpoint
app.MapGet("/api/search", async (
    string query, 
    string lang, 
    IConfiguration config, 
    IHttpClientFactory httpClientFactory) =>
{
    // Ensure the query isn't empty to avoid bad API calls
    if (string.IsNullOrWhiteSpace(query))
    {
        return Results.BadRequest("Search query cannot be empty.");
    }

    // Grab the settings from appsettings.json
    var apiKey = config["Pixabay:ApiKey"];
    var baseUrl = config["Pixabay:BaseUrl"];

    if (string.IsNullOrEmpty(apiKey))
    {
        return Results.StatusCode(500); // Server error if API key is missing
    }

    // Construct the secure, child-safe Pixabay URL
    // We enforce safesearch=true and restrict it to illustrations/photos
    var requestUrl = $"{baseUrl}?key={apiKey}&q={Uri.EscapeDataString(query)}&lang={lang}&safesearch=true&image_type=illustration";

    try
    {
        // Create the client and make the request from the SERVER, not the phone
        var client = httpClientFactory.CreateClient();
        var response = await client.GetAsync(requestUrl);

        if (!response.IsSuccessStatusCode)
        {
             return Results.StatusCode((int)response.StatusCode);
        }

        // Read the JSON response from Pixabay
        var jsonResponse = await response.Content.ReadAsStringAsync();
        
        // Parse the JSON to extract JUST the data you need (e.g., image URLs)
        // This ensures you aren't passing unnecessary third-party tracking data back to the app
        using var document = JsonDocument.Parse(jsonResponse);
        var root = document.RootElement;
        
        var safeImages = new List<object>();
        
        if (root.TryGetProperty("hits", out var hits))
        {
            foreach (var hit in hits.EnumerateArray())
            {
                safeImages.Add(new {
                    Id = hit.GetProperty("id").GetInt32(),
                    PreviewUrl = hit.GetProperty("previewURL").GetString(),
                    LargeUrl = hit.GetProperty("largeImageURL").GetString(),
                    Tags = hit.GetProperty("tags").GetString()
                });
            }
        }

        // Return the cleansed, safe list back to your Flutter app
        return Results.Ok(safeImages);
    }
    catch (Exception ex)
    {
        // Log the error (in production, use a proper logger)
        Console.WriteLine($"Error fetching from Pixabay: {ex.Message}");
        return Results.StatusCode(500);
    }
});

// 3. Category-browsing / general image proxy endpoint (replaces the client's former direct Pixabay calls)
app.MapGet("/api/images", async (
    string q,
    IConfiguration config,
    IHttpClientFactory httpClientFactory,
    int page = 1,
    int perPage = 20,
    string? category = null,
    bool safesearch = true) =>
{
    if (string.IsNullOrWhiteSpace(q))
    {
        return Results.BadRequest("Query cannot be empty.");
    }

    // Clamp paging params so a decompiled client can't abuse the Pixabay quota
    var pageNumber = page < 1 ? 1 : page;
    var pageSize = perPage is < 1 or > 50 ? 20 : perPage;

    var apiKey = config["Pixabay:ApiKey"];
    var baseUrl = config["Pixabay:BaseUrl"];

    if (string.IsNullOrEmpty(apiKey) || string.IsNullOrEmpty(baseUrl))
    {
        return Results.StatusCode(500);
    }

    var requestUrl = $"{baseUrl}?key={apiKey}&q={Uri.EscapeDataString(q)}" +
        $"&page={pageNumber}&per_page={pageSize}&image_type=photo" +
        $"&safesearch={(safesearch ? "true" : "false")}";

    if (!string.IsNullOrWhiteSpace(category))
    {
        requestUrl += $"&category={Uri.EscapeDataString(category)}";
    }

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
        var root = document.RootElement;

        var images = new List<object>();

        if (root.TryGetProperty("hits", out var hits))
        {
            foreach (var hit in hits.EnumerateArray())
            {
                var user = hit.GetProperty("user").GetString();
                var userId = hit.GetProperty("user_id").GetInt32();
                var webformatUrl = hit.GetProperty("webformatURL").GetString();

                // Shape matches what the Flutter client already expects (id/url/largeUrl/...)
                images.Add(new
                {
                    Id = hit.GetProperty("id").GetInt32(),
                    Url = webformatUrl,
                    LargeUrl = hit.GetProperty("largeImageURL").GetString(),
                    Photographer = user,
                    PhotoLink = $"https://pixabay.com/users/{user}-{userId}/",
                    Download = webformatUrl,
                    Title = hit.GetProperty("tags").GetString(),
                    Likes = hit.GetProperty("likes").GetInt32(),
                });
            }
        }

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