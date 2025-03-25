import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadButton extends StatelessWidget {
  final String imageUrl;

  const DownloadButton({super.key, required this.imageUrl});

  Future<void> _downloadImage(BuildContext context, String url) async {
    // Check storage permissions
    if (await Permission.storage.request().isGranted) {
      try {
        // Get the directory to save the image
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/${url.split('/').last}';

        // Download the image
        final response = await Dio().download(url, filePath);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image downloaded to $filePath')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to download image')),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error downloading image: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading image')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.download),
      onPressed: () => _downloadImage(context, imageUrl),
    );
  }
}