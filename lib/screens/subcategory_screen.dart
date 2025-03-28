import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:happy_view/services/unsplash_service.dart.dart';
import 'package:http/http.dart' as http;
import 'picture_display_screen.dart';

class SubcategoryScreen extends StatefulWidget {
  final String category;

  const SubcategoryScreen({super.key, required this.category});

  @override
  SubcategoryScreenState createState() => SubcategoryScreenState();
}

class SubcategoryScreenState extends State<SubcategoryScreen> {
  static final Map<String, List<Map<String, String>>> _cache =
      {}; // Cache for subcategories
  late Future<List<Map<String, String>>> subcategories;

  @override
  void initState() {
    super.initState();
    subcategories = _getSubcategories(widget.category);
  }

  // Get subcategories, either from cache or by fetching
  Future<List<Map<String, String>>> _getSubcategories(String category) async {
    if (_cache.containsKey(category)) {
      // Return cached data if available
      return _cache[category]!;
    }

    // Fetch subcategories and cache the result
    final fetchedSubcategories = await fetchSubcategories(category);
    _cache[category] = fetchedSubcategories;
    return fetchedSubcategories;
  }

  // Fetch subcategories and their images from Unsplash
  Future<List<Map<String, String>>> fetchSubcategories(String category) async {
    const fallbackImage =
        'https://via.placeholder.com/300'; // Fallback image URL
    final accessKey = UnsplashService.accessKey; // Unsplash API key

    // Define category topics
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
        'farm-animals'
      ],
      'nature': [
        'trees',
        'flowers',
        'forests',
        'mountains',
        'oceans',
        'snow',
        'sunsets',
        'waterfalls',
        'rivers',
        'lakes'
      ],
      'space': [
        'planets',
        'stars',
        'galaxies',
        'astronauts',
        'telescopes',
        'satellites'
      ],
      'architecture': [
        'buildings',
        'bridges',
        'skyscrapers',
        'houses',
        'interiors',
        'exteriors',
        'landmarks',
        'monuments',
        'towers',
        'castles'
      ],
      'food-drink': [
        'fruits',
        'vegetables',
        'desserts',
        'beverages',
        'fast-food',
        'seafood',
        'meat',
        'dairy',
        'baked-goods',
        'healthy-food'
      ],
      'shapes': [
        'circles',
        'squares',
        'triangles',
        'rectangles',
        'hexagons',
        'stars',
        'hearts',
        'spirals',
        'diamonds',
        'ovals'
      ],
      'vehicles': [
        'cars',
        'motorcycles',
        'trucks',
        'bicycles',
        'buses',
        'trains',
        'airplanes',
        'boats',
        'helicopters',
        'scooters'
      ],
    };

    final topics = categoryTopics[category.toLowerCase()] ?? [];
    final List<Future<Map<String, String>>> fetchTasks =
        topics.map((topic) async {
      try {
        final response = await http.get(
          Uri.parse(
              'https://api.unsplash.com/search/photos?query=$topic&client_id=$accessKey&per_page=1'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          if (data['results'].isNotEmpty) {
            return {
              'name': topic.replaceAll('-', ' ').toUpperCase(),
              'query': topic,
              'image': data['results'][0]['urls']['regular']
                  as String, // Ensure this is a String
            };
          }
        }
      } catch (e) {
        // Log the error (optional)
        if (kDebugMode) {
          print('Error fetching topic "$topic": $e');
        }
      }

      // Fallback for failed requests
      return {
        'name': topic.replaceAll('-', ' ').toUpperCase(),
        'query': topic,
        'image': fallbackImage,
      };
    }).toList();

    return Future.wait(fetchTasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category} Subcategories',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: subcategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text('Oops! Something went wrong. 😕'));
          }

          final subcategories = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 1.0,
              ),
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                final subcategory = subcategories[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PictureDisplayScreen(query: subcategory['query']!),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Stack(
                      children: [
                        // Subcategory image
                        Positioned.fill(
                          child: Image.network(
                            subcategory['image']!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image_not_supported,
                                    size: 80, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        // Dark overlay for text readability
                        Container(
                          color: Colors.black.withOpacity(0.3),
                        ),
                        // Subcategory name
                        Center(
                          child: Text(
                            subcategory['name']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 6,
                                  color: Colors.black54,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
