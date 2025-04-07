import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img; // For image conversion
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
class DownloadButton extends StatefulWidget {
  final String imageUrl;
  final String? imageId; // Optional ID for filename
  final String? location; // Optional location for Unsplash attribution

  const DownloadButton({
    super.key,
    required this.imageUrl,
    this.imageId,
    this.location,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool _isLoading = false;

  Future<void> _downloadAndSaveImage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // Check and request permissions
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {      if (!mounted) return;

          throw Exception(
            
              AppLocalizations.of(context)!.storagePermissionDenied);
        }
      }

      // Download image bytes
      final dio = Dio();
      final response = await dio.get(
        widget.imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      // Convert to JPEG if needed (especially for AVIF)
      final Uint8List jpegBytes = await _convertToJpegIfNeeded(response.data);

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/${_generateImageName()}.jpg'; // Force .jpg extension
      final file = File(filePath);

      // Write JPEG file
      await file.writeAsBytes(jpegBytes);

      // Save to gallery using gal
      await Gal.putImage(filePath);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.imageSavedToGallery),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.error}: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Uint8List> _convertToJpegIfNeeded(Uint8List originalBytes) async {
    try {
      // Decode image (works for AVIF, WebP, PNG, etc.)
      final image = img.decodeImage(originalBytes);
      if (image == null) {
        throw Exception(AppLocalizations.of(context)!.failedToDecodeImage);
      }

      // Encode as JPEG
      return Uint8List.fromList(img.encodeJpg(image, quality: 95));
    } catch (e) {
      // If conversion fails, return original (might work for some devices)
      return originalBytes;
    }
  }

  String _generateImageName() {
    // Use provided ID or fallback to timestamp
    return widget.imageId ??
        'unsplash_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: SpinKitThreeInOut( 
                            color: Color.fromARGB(255, 8, 127, 148),
                            size: 30.0,
                          ),
            )
          : const Icon(Icons.download),
      onPressed: _downloadAndSaveImage,
      tooltip: AppLocalizations.of(context)!.saveToGallery,
    );
  }
}
