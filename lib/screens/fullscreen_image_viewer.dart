// 1. Replace FullScreenImageView with an optimized version
// File: fullscreen_image_viewer.dart

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import 'package:url_launcher/url_launcher.dart';

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  final String photographerName;
  final String photoLink;

  const FullScreenImageView({
    super.key,
    required this.imageUrl,
    required this.photographerName,
    required this.photoLink,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
      //  title: const Text('Image Viewer'),
      ),
      body: Stack(
        children: [
          Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      localizations.photoBy,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final Uri photoUri = Uri.parse(photoLink);
                        if (await canLaunchUrl(photoUri)) {
                          await launchUrl(photoUri);
                        }
                      },
                      child: Text(
                        photographerName,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Text(
                      ' on Unsplash',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}

