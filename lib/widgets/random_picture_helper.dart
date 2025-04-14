
  import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:happy_view/l10n/app_localizations.dart';
import 'package:happy_view/screens/fullscreen_image_viewer.dart';
import 'package:happy_view/services/pixabay_services.dart';
import 'package:happy_view/widgets/categories.dart';
import 'package:happy_view/widgets/subcategory_data.dart';

Future<void> showRandomPicture(BuildContext context) async {
  try {
    // Get all available categories
    final localizations = AppLocalizations.of(context);
    final categories = getCategories(localizations!);
    
    // Select a random category
    final random = Random();
    final randomCategory = categories[random.nextInt(categories.length)];
    final categoryQuery = randomCategory['query'];
    
    // Get subcategories for this category
    final subcategories = SubcategoryData.getCategoryTopics(categoryQuery);
    
    // Select a random subcategory or use the main category
    final randomQuery = subcategories.isNotEmpty 
        ? subcategories[random.nextInt(subcategories.length)]
        : categoryQuery;
    
    // Fetch images from Pixabay
    final images = await PixabayService.fetchImages(
      randomQuery,
      // Add safety parameters
      safesearch: true, // Enable Pixabay's safesearch
    );
    
    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No images found for $randomQuery')),
      );
      return;
    }
    
    // Select a random image from the results
    final randomImage = images[random.nextInt(images.length)];
    
    // Navigate to show the image
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(
          imageUrl: randomImage['largeUrl'] ?? randomImage['url'],
          photographerName: randomImage['photographer'],
          photoLink: randomImage['photoLink'],
          downloadUrl: randomImage['download'],
          images: [randomImage], // Single image array
          initialIndex: 0,
          query: randomQuery,
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load random image')),
    );
    if (kDebugMode) print('Error loading random image: $e');
  }
}

