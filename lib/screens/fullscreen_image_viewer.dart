// 1. Replace FullScreenImageView with an optimized version
// File: fullscreen_image_viewer.dart

import 'package:flutter/material.dart';

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
                    const Text(
                      'Photo by ',
                      style: TextStyle(
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

// 2. Optimize the showRandomPicture function in home_screen.dart
/* Future<void> showRandomPicture(BuildContext context) async {
 if (!context.mounted) return; // ✅ Ensure context is valid
 */ 
 /*  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final random = Random();
    final topics = [
      'animals',
      'nature',
      'space',
      'food-drink',
      'shapes',
      'vehicles',
    ];
    final randomTopic = topics[random.nextInt(topics.length)];

    // Ensure widget is still mounted before closing the dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    final response = await http
        .get(
      Uri.parse(
        'https://api.unsplash.com/photos/random?query=$randomTopic&client_id=rymj4kWDUWfggopViVeWw6g',
      ),
    )
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Connection timed out');
      },
    );

    if (!context.mounted) return; // ✅ Ensure context is valid before using it

    // Handle response
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final imageUrl = data['urls']['regular'];
      final photographerName = data['user']['name'];
      final photoLink = data['links']['html'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageView(
            imageUrl: imageUrl,
            photographerName: photographerName,
            photoLink: photoLink,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load image')),
      );
    }
  } catch (e) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
// 3. Optimize SubcategoryScreen to prevent excessive API calls
// File: subcategory_screen.dart (partial)

// Replace the fetchAnimalCategories function with this optimized version:
Future<List<Map<String, String>>> fetchAnimalCategories(String category) async {
  String accessKey = UnsplashService.accessKey;

  final Map<String, List<String>> categoryTopics = {
    'animals': [
      'mammals',
      'birds',
      'reptiles',
      'marine-life',
      'insects',
      'amphibians',
      'wildlife',
      'pets',
      'farm-animals',
    ],
    // Keep other categories as they are
  };

  List<String> topics = categoryTopics[category.toLowerCase()] ?? [];
  List<Map<String, String>> categories = [];

  // Create a batch of futures to run in parallel instead of sequentially
  List<Future<Map<String, String>>> futures = [];

  for (String topic in topics) {
    futures.add(_fetchTopicImage(topic, accessKey));
  }

  // Wait for all futures to complete
  final results = await Future.wait(futures);
  categories.addAll(results);

  return categories;
}

// Helper method to fetch a single topic image
Future<Map<String, String>> _fetchTopicImage(
    String topic, String accessKey) async {
  try {
    final response = await http
        .get(
          Uri.parse(
            'https://api.unsplash.com/search/photos?query=$topic&client_id=$accessKey&per_page=1',
          ),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        return {
          'name': topic.replaceAll('-', ' ').toUpperCase(),
          'query': topic,
          'image': data['results'][0]['urls']
              ['small'], // Use smaller image size
        };
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching image for $topic: $e');
    }
  }

  // Fallback
  return {
    'name': topic.replaceAll('-', ' ').toUpperCase(),
    'query': topic,
    'image': 'https://source.unsplash.com/featured/?$topic',
  };
} */
