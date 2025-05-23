
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
        androidRelativePath: "Pictures/happyview",

      );

      if (!mounted) return;
      if (result.isSuccess) {
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
