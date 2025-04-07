// File: unsplash_download_service.dart
import 'package:http/http.dart' as http;

class UnsplashDownloadService {
  static Future<void> triggerDownload(String downloadUrl) async {
    try {
      // According to Unsplash API guidelines, we should trigger the download
      // by making a GET request to the download location
      final response = await http.get(Uri.parse(downloadUrl));
      
      if (response.statusCode == 200) {
        // The download has been registered with Unsplash
        // The actual download happens via the redirected URL
        // Note: On mobile, we might want to handle the actual download differently
      }
    } catch (e) {
      throw Exception('Failed to trigger download: $e');
    }
  }
}