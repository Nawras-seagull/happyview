using System.Collections.Concurrent;
using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Threading.RateLimiting;
using Microsoft.Extensions.Caching.Memory;

namespace HappyviewProxy.Services;

public sealed record PixabayImageResult(
    int Id,
    string Url,
    string LargeUrl,
    string? Photographer,
    string? PhotoLink,
    string? Download,
    string? Title,
    int Likes);

public sealed class PixabayProxyService
{
    private static readonly TimeSpan CacheDuration = TimeSpan.FromHours(24);
    private const int MaxRetryAttempts = 3;

    private readonly HttpClient _httpClient;
    private readonly IMemoryCache _cache;
    private readonly ILogger<PixabayProxyService> _logger;
    private readonly FixedWindowRateLimiter _pixabayLimiter;
    private readonly IConfiguration _configuration;
    private readonly ConcurrentDictionary<string, Lazy<Task<List<PixabayImageResult>>>> _inFlightRequests = new();

    public PixabayProxyService(
        HttpClient httpClient,
        IMemoryCache cache,
        ILogger<PixabayProxyService> logger,
        FixedWindowRateLimiter pixabayLimiter,
        IConfiguration configuration)
    {
        _httpClient = httpClient;
        _cache = cache;
        _logger = logger;
        _pixabayLimiter = pixabayLimiter;
        _configuration = configuration;
    }

    public async Task<IReadOnlyList<PixabayImageResult>> GetImagesAsync(
        string query,
        string? category,
        int page,
        int perPage,
        bool safesearch,
        CancellationToken cancellationToken = default)
    {
        var cacheKey = BuildCacheKey(query, category);

        if (_cache.TryGetValue(cacheKey, out IReadOnlyList<PixabayImageResult>? cachedImages) && cachedImages is not null)
        {
            _logger.LogInformation("Pixabay cache hit for normalized cache key.");
            return cachedImages;
        }

        _logger.LogInformation("Pixabay cache miss for normalized cache key. Coalescing in-flight request.");

        var request = _inFlightRequests.GetOrAdd(
            cacheKey,
            _ => new Lazy<Task<List<PixabayImageResult>>>(
                () => FetchAndCacheAsync(cacheKey, query, category, page, perPage, safesearch, cancellationToken),
                LazyThreadSafetyMode.ExecutionAndPublication));

        try
        {
            return await request.Value.WaitAsync(cancellationToken);
        }
        finally
        {
            if (_inFlightRequests.TryGetValue(cacheKey, out var currentRequest) && ReferenceEquals(currentRequest, request))
            {
                _inFlightRequests.TryRemove(cacheKey, out _);
            }
        }
    }

    private async Task<List<PixabayImageResult>> FetchAndCacheAsync(
        string cacheKey,
        string query,
        string? category,
        int page,
        int perPage,
        bool safesearch,
        CancellationToken cancellationToken)
    {
        var requestUrl = BuildPixabayRequestUrl(query, category, page, perPage, safesearch);
        var images = await FetchAndParsePixabayAsync(requestUrl, cancellationToken);

        _cache.Set(cacheKey, images, CacheDuration);
        _logger.LogInformation("Pixabay cache populated for 24 hours.");
        return images;
    }

    private async Task<List<PixabayImageResult>> FetchAndParsePixabayAsync(string requestUrl, CancellationToken cancellationToken)
    {
        for (var attempt = 1; ; attempt++)
        {
            await _pixabayLimiter.AcquireAsync(permitCount: 1, cancellationToken);

            using var response = await _httpClient.GetAsync(requestUrl, HttpCompletionOption.ResponseHeadersRead, cancellationToken);

            if (response.StatusCode == HttpStatusCode.TooManyRequests)
            {
                _logger.LogWarning("Pixabay returned HTTP 429 while fetching images. Rate-limited response observed.");

                if (attempt >= MaxRetryAttempts)
                {
                    throw new HttpRequestException($"Pixabay rate limit exceeded after {MaxRetryAttempts} attempts.");
                }

                var retryDelay = GetRetryDelay(response.Headers, attempt);
                await Task.Delay(retryDelay, cancellationToken);
                continue;
            }

            if (!response.IsSuccessStatusCode)
            {
                throw new HttpRequestException($"Pixabay request failed with status code {(int)response.StatusCode}.");
            }

            var json = await response.Content.ReadAsStringAsync(cancellationToken);
            return ParseImages(json);
        }
    }

    private static TimeSpan GetRetryDelay(HttpResponseHeaders headers, int attempt)
    {
        if (headers.TryGetValues("Retry-After", out var values))
        {
            var value = values.FirstOrDefault();
            if (!string.IsNullOrWhiteSpace(value))
            {
                if (int.TryParse(value, out var seconds))
                {
                    return TimeSpan.FromSeconds(seconds);
                }

                if (DateTimeOffset.TryParse(value, out var retryAt))
                {
                    var delay = retryAt - DateTimeOffset.UtcNow;
                    return delay > TimeSpan.Zero ? delay : TimeSpan.Zero;
                }
            }
        }

        return TimeSpan.FromSeconds(Math.Pow(2, attempt - 1));
    }

    private static List<PixabayImageResult> ParseImages(string json)
    {
        using var document = JsonDocument.Parse(json);
        var root = document.RootElement;
        var images = new List<PixabayImageResult>();

        if (!root.TryGetProperty("hits", out var hits))
        {
            return images;
        }

        foreach (var hit in hits.EnumerateArray())
        {
            var user = hit.TryGetProperty("user", out var userElement) ? userElement.GetString() : null;
            var userId = hit.TryGetProperty("user_id", out var userIdElement) ? userIdElement.GetInt32() : 0;
            var webformatUrl = hit.TryGetProperty("webformatURL", out var webformatElement)
                ? webformatElement.GetString() ?? string.Empty
                : string.Empty;

            images.Add(new PixabayImageResult(
                Id: hit.TryGetProperty("id", out var idElement) ? idElement.GetInt32() : 0,
                Url: webformatUrl,
                LargeUrl: hit.TryGetProperty("largeImageURL", out var largeImageElement)
                    ? largeImageElement.GetString() ?? string.Empty
                    : string.Empty,
                Photographer: user,
                PhotoLink: string.IsNullOrWhiteSpace(user) ? null : $"https://pixabay.com/users/{user}-{userId}/",
                Download: webformatUrl,
                Title: hit.TryGetProperty("tags", out var tagsElement) ? tagsElement.GetString() : null,
                Likes: hit.TryGetProperty("likes", out var likesElement) ? likesElement.GetInt32() : 0));
        }

        return images;
    }

    private string BuildPixabayRequestUrl(string query, string? category, int page, int perPage, bool safesearch)
    {
        var apiKey = _configuration["Pixabay:ApiKey"]
            ?? Environment.GetEnvironmentVariable("PIXABAY_API_KEY")
            ?? throw new InvalidOperationException("Pixabay API key is not configured.");

        var baseUrl = _configuration["Pixabay:BaseUrl"] ?? "https://pixabay.com/api/";

        var requestUrl = $"{baseUrl}?key={Uri.EscapeDataString(apiKey)}&q={Uri.EscapeDataString(query)}" +
            $"&page={page}&per_page={perPage}&image_type=photo" +
            $"&safesearch={(safesearch ? "true" : "false")}";

        if (!string.IsNullOrWhiteSpace(category))
        {
            requestUrl += $"&category={Uri.EscapeDataString(category.Trim())}";
        }

        return requestUrl;
    }

    private static string BuildCacheKey(string query, string? category)
    {
        var normalizedQuery = query.Trim();
        var normalizedCategory = category?.Trim() ?? string.Empty;

        return $"pixabay:{normalizedQuery.ToLowerInvariant()}|{normalizedCategory.ToLowerInvariant()}";
    }
}
