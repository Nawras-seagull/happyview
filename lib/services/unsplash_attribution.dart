import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class UnsplashAttribution {
  /// Generates a styled text widget with photographer attribution
  ///
  /// [imageData] should be a map containing:
  /// - 'photographer': Photographer's name
  /// - 'photographerLink': Link to photographer's Unsplash profile
  /// - 'photoLink': Link to the specific photo
  static Widget buildAttribution(
    BuildContext context,
    Map<String, dynamic> imageData, {
    Color? textColor,
    double fontSize = 14.0,
  }) {
    final localizations = AppLocalizations.of(context)!;
    textColor ??= Colors.white;

    return RichText(
      text: TextSpan(
        style: TextStyle(color: textColor, fontSize: fontSize),
        children: [
          TextSpan(text: localizations.photoBy),
          TextSpan(
            text: imageData['photographer'] ?? imageData['user']['name']??  localizations.unknownPhotographer,
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchUrl(imageData['photographerLink']),
          ),
          TextSpan(text:localizations.on,style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
          TextSpan(
            text: 'Unsplash',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchUrl('https://unsplash.com'),
          ),
        ],
      ),
    );
  }

  /// Extracts attribution information from Unsplash API response
  static Map<String, String> extractAttributionData(Map<String, dynamic> apiResponse) {
    return {
'photographer': (apiResponse['user']['name']?.length ?? 0) > 20
    ? '${apiResponse['user']['name']?.substring(0, 20)}...'
    : apiResponse['user']['name'] ?? 'Unknown Photographer',      'photographerLink': apiResponse['user']['links']['html'] ?? '',
      'photoLink': apiResponse['links']['html'] ?? '',
      // Add download URL extraction (use either 'download' or 'download_location' depending on API version)
      'downloadUrl': apiResponse['links']['download'] ?? apiResponse['links']['download_location'] ?? '',
    };
  }

  /// Launch URL safely
  static Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) {
      if (kDebugMode) {
        print('Invalid URL: $url');
      }
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching URL: $e');
      }
    }
  }
} 