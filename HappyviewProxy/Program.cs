using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// 1. Register HttpClient so we can make external web requests
builder.Services.AddHttpClient();

var app = builder.Build();

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

app.Run();