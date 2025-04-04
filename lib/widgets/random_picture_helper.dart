import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:happy_view/screens/fullscreen_image_viewer.dart';
import 'package:happy_view/widgets/categories.dart'; // Import categories.dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization

// Top-level function for parsing JSON off the main thread
Map<String, dynamic> parseJson(String responseBody) {
  return json.decode(responseBody);
}

Future<void> showRandomPicture(BuildContext context) async {
  final random = Random();
  final localizations = AppLocalizations.of(context)!;

  // Fetch categories dynamically
  final categories = getCategories(localizations);
  final topics = categories.map((category) => category['query']).toList();

  // Select a random topic
  final randomTopic = topics[random.nextInt(topics.length)];

  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: SpinKitThreeInOut( 
                            color: Color.fromARGB(255, 8, 127, 148),
                            size: 30.0,
                          ),
      ),
    );

    // Make the API request
    final response = await http.get(
      Uri.parse(
        'https://api.unsplash.com/photos/random?query=$randomTopic&client_id=rymj4kWDUWfggopViVtniGBy1FV6alObBnbHlVeWw6g',
      ),
    );

    if (!context.mounted) return;
    Navigator.pop(context); // Remove loading indicator

    if (response.statusCode == 200) {
      // Parse JSON off the main thread
      final data = await compute(parseJson, response.body);

      if (!context.mounted) return;

      // Navigate to image view
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageView(
            imageUrl: data['urls']['regular'],
            photographerName: data['user']['name'],
            photoLink: data['links']['html'],
          ),
        ),
      );
    } else {
      if (!context.mounted) return;
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load image')),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    // Ensure we always dismiss the loading dialog even on error
    if (ModalRoute.of(context)?.isCurrent != true) {
      Navigator.pop(context);
    }

    // Display error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
