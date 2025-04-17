/* import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img; // For image conversion
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';

/* class UnsplashDownloadService {
  static Future<void> triggerDownload(String downloadUrl) async {
    try {
      // According to Unsplash API guidelines, we should trigger the download
      // by making a GET request to the download location
      final response = await http.get(Uri.parse(downloadUrl));
      // Check if the response is successful
       
      
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
 */
class DownloadButton extends StatefulWidget {
  final String imageUrl;
  final String? imageId; // Optional ID for filename
  final String? location; // Optional location for Unsplash attribution
  final String? downloadUrl; // Optional download URL for Unsplash tracking

  const DownloadButton({
    super.key,
    required this.imageUrl,
    this.imageId,
    this.location,
    this.downloadUrl,
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
      // Trigger Unsplash download tracking if URL is provided
    /*   if (widget.downloadUrl != null) {
        await UnsplashDownloadService.triggerDownload(widget.downloadUrl!);
      } */
      
      // Check and request permissions
      if (Platform.isAndroid) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          if (!mounted) return;
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
              
            )
          : const Icon(Icons.download),
      onPressed: _downloadAndSaveImage,
      tooltip: AppLocalizations.of(context)!.saveToGallery,
    );
  }
} */
import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import '../l10n/app_localizations.dart';

class DownloadButton extends StatefulWidget {
  final String imageUrl;
  final String? imageId;
  final String? location;
  final String? downloadUrl;

  const DownloadButton({
    super.key,
    required this.imageUrl,
    this.imageId,
    this.location,
    this.downloadUrl,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool _isLoading = false;

Future<bool> checkAndRequestPermissions({required bool skipIfExists}) async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    return false; // Only Android and iOS platforms are supported
  }
  if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = deviceInfo.version.sdkInt;

    if (skipIfExists) {
      // Read permission is required to check if the file already exists
      return sdkInt >= 33
          ? await Permission.photos.request().isGranted
          : await Permission.storage.request().isGranted;
    } else {
      // No read permission required for Android SDK 29 and above
      return sdkInt >= 29 ? true : await Permission.storage.request().isGranted;
    }
  } else if (Platform.isIOS) {
    // iOS permission for saving images to the gallery
    return skipIfExists
        ? await Permission.photos.request().isGranted
        : await Permission.photosAddOnly.request().isGranted;
  }

  return false; // Unsupported platforms
}

  Future<void> _downloadAndSaveImage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final hasPermission = await checkAndRequestPermissions(skipIfExists: true);
      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.storagePermissionDenied),
          ),
        );
        
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        widget.imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final Uint8List jpegBytes = await _convertToJpegIfNeeded(response.data);

      final result = await SaverGallery.saveImage(
        jpegBytes,
        fileName: _generateImageName(),
        skipIfExists: false, // or true, depending on your desired behavior
        androidRelativePath: "Pictures/YourAppName",

      );

      if (!mounted) return;
      if (result.isSuccess!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.imageSavedToGallery),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception("Failed to save image to gallery.");
      }
    } catch (e) {
      if (!mounted) return;
      String errorMsg =
          e is DioException ? e.message ?? e.toString() : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${AppLocalizations.of(context)!.error}: $errorMsg'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Uint8List> _convertToJpegIfNeeded(Uint8List originalBytes) async {
    try {
      final image = img.decodeImage(originalBytes);
      if (image == null) {
        throw Exception(AppLocalizations.of(context)!.failedToDecodeImage);
      }
      return Uint8List.fromList(img.encodeJpg(image, quality: 95));
    } catch (_) {
      return originalBytes; // fallback
    }
  }

  String _generateImageName() {
    final base =
        widget.imageId ?? 'pixabay_${DateTime.now().millisecondsSinceEpoch}';
    return base.replaceAll(RegExp(r'[^ -]+'), '_');
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download),
      onPressed: _downloadAndSaveImage,
      tooltip: AppLocalizations.of(context)!.saveToGallery,
    );
  }
}
