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
           TextSpan(text:localizations.photoBy,
),
          TextSpan(
            text: imageData['photographer'] ?? localizations.unknownPhotographer,
            style: TextStyle(
              color: Colors.blue[200],
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchUrl(imageData['photographerLink']),
          ),
           TextSpan(text: localizations.on),
          TextSpan(
            text: 'Unsplash',
            style: TextStyle(
              color: Colors.blue[200],
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

  /// Extracts attribution information from Unsplash API response
  static Map<String, String> extractAttributionData(Map<String, dynamic> apiResponse) {
    return {
      'photographer': apiResponse['user']['name'] ?? 'Unknown Photographer',
      'photographerLink': apiResponse['user']['links']['html'] ?? '',
      'photoLink': apiResponse['links']['html'] ?? '',
    };
  }
}