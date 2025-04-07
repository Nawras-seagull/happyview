// 1. Replace FullScreenImageView with an optimized version
// File: fullscreen_image_viewer.dart

import 'package:flutter/material.dart';
import 'package:happy_view/services/unsplash_download_services.dart';
import '../l10n/app_localizations.dart';

import 'package:url_launcher/url_launcher.dart';

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  final String photographerName;
  final String photoLink;
  final String downloadUrl; // Add download URL parameter



  const FullScreenImageView({
    super.key,
    required this.imageUrl,
    required this.photographerName,
    required this.photoLink,
        required this.downloadUrl, // Require download URL
    
  });

  Future<void> _handleDownload(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      await UnsplashDownloadService.triggerDownload(downloadUrl);
      
      // Show a snackbar to confirm download
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.downloadStarted),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.downloadFailed),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _handleDownload(context),
            tooltip: localizations.download,
          ),
        ],
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
                      child:
                       Text(
                        photographerName,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                     Text(localizations.on),
          
            GestureDetector(
              onTap: () async {
                final Uri photoUri = Uri.parse('https://unsplash.com');
                if (await canLaunchUrl(photoUri)) {
                  await launchUrl(photoUri);
                }
              },
              child: Text(
                'Unsplash',
                style: TextStyle(
                  color: Colors.blue[200],
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
              
             
        
          
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

