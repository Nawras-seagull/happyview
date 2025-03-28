/* import 'dart:async';
import 'dart:convert';
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
  late Future<List<Map<String, String>>> subcategories;
  @override
  void initState() {
    super.initState();
    subcategories = fetchAnimalCategories(widget.category);
  }

Future<List<Map<String, String>>> fetchAnimalCategories(String category) async {
     String accessKey = UnsplashService.accessKey; // Replace with your Unsplash API key

    final Map<String, List<String>> categoryTopics = {
      'animals': ['mammals', 'birds', 'reptiles', 'marine-life', 'insects', 'amphibians', 'wildlife', 'pets', 'farm-animals'],
      'nature': ['trees','flower','forests', 'mountains', 'oceans', 'snow','sunsets','waterfalls','rivers','lakes'],
      'space': ['planets', 'stars', 'galaxies', 'astronauts', 'telescopes', 'satellites'],
      'architecture': ['buildings', 'bridges', 'skyscrapers', 'houses', 'interiors', 'exteriors', 'landmarks', 'monuments', 'towers', 'castles'],
      'food-drink': ['fruits', 'vegetables', 'desserts','beverages','fast-food','seafood','meat','dairy','baked-goods','healthy-food'],
      'shapes': ['circles', 'squares', 'triangles', 'rectangles', 'hexagons', 'stars', 'hearts', 'spirals', 'diamonds', 'ovals'],
      'vehicles': ['cars', 'motorcycles', 'trucks', 'bicycles', 'buses', 'trains', 'airplanes', 'boats', 'helicopters', 'scooters']
    };

    List<String> topics = categoryTopics[category.toLowerCase()] ?? [];
    List<Map<String, String>> categories = [];

    for (String topic in topics) {
      final response = await http.get(
        Uri.parse('https://api.unsplash.com/search/photos?query=$topic&client_id=$accessKey&per_page=1')
      );

      if (response.statusCode == 200) {  

        final Map<String, dynamic> data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          categories.add({
            'name': topic.replaceAll('-', ' ').toUpperCase(),
            'query': topic,
            'image': data['results'][0]['urls']['regular'], // Fetching first image
          });
        }
      } else {
        categories.add({
          'name': topic.replaceAll('-', ' ').toUpperCase(),
          'query': topic,
          'image': 'https://source.unsplash.com/featured/?$topic', // Fallback image
        });
      }
    }
    return categories;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Subcategories', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orangeAccent,
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: subcategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Oops! Something went wrong. 😕'));
          }

          final subcategories = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                        builder: (context) => PictureDisplayScreen(query: subcategory['query']!),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            subcategory['image']!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        Container(
                          color: Colors.black.withValues(alpha: 0.3), // Slight dark overlay for better text readability
                        ),
                        Center(
                          child: Text(
                            //use translated name 
                            // Add your translation service here
                            
                            subcategory['name']!,

                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 6,
                                  color: Colors.black.withValues(alpha: 0.3),
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
} */

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:happy_view/services/unsplash_service.dart.dart';
import 'package:http/http.dart' as http;
import 'picture_display_screen.dart';

// Custom cache manager
final _customCacheManager = CacheManager(
  Config(
    'happyViewCache',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 200,
  ),
);

class SubcategoryScreen extends StatefulWidget {
  final String category;

  const SubcategoryScreen({super.key, required this.category});

  @override
  SubcategoryScreenState createState() => SubcategoryScreenState();
}

class SubcategoryScreenState extends State<SubcategoryScreen> {
  static final Map<String, List<Map<String, String>>> _categoryCache = {};
  final Map<String, ImageProvider> _imageCache = {};
  static const String fallbackImage = 'https://via.placeholder.com/300';
  late final Future<List<Map<String, String>>> subcategories = 
      _getSubcategories(widget.category).catchError((error) {
    if (kDebugMode) print('Error loading subcategories: $error');
    return <Map<String, String>>[];
  });

  Future<List<Map<String, String>>> _getSubcategories(String category) async {
    if (_categoryCache.containsKey(category)) {
      return _categoryCache[category]!;
    }
    
    final fetched = await fetchSubcategories(category);
    _categoryCache[category] = fetched;
    return fetched;
  }

  Future<List<Map<String, String>>> fetchSubcategories(String category) async {
    final topics = _getCategoryTopics(category);
    
    final results = await Future.wait(
      topics.map((topic) => _fetchTopic(topic)) as Iterable<Future>,
    );
    return results.where((item) => item != null).cast<Map<String, String>>().toList();
  }

  List _getCategoryTopics(String category) {
    return {
      'animals': ['mammals', 'birds', 'reptiles', 'marine-life', 'insects', 'amphibians', 'wildlife', 'pets', 'farm-animals'],
      'nature': ['trees','flower','forests', 'mountains', 'oceans', 'snow','sunsets','waterfalls','rivers','lakes'],
      'space': ['planets', 'stars', 'galaxies', 'astronauts', 'telescopes', 'satellites'],
      'architecture': ['buildings', 'bridges', 'skyscrapers', 'houses', 'interiors', 'exteriors', 'landmarks', 'monuments', 'towers', 'castles'],
      'food-drink': ['fruits', 'vegetables', 'desserts','beverages','fast-food','seafood','meat','dairy','baked-goods','healthy-food'],
      'shapes': ['circles', 'squares', 'triangles', 'rectangles', 'hexagons', 'stars', 'hearts', 'spirals', 'diamonds', 'ovals'],
      'vehicles': ['cars', 'motorcycles', 'trucks', 'bicycles', 'buses', 'trains', 'airplanes', 'boats', 'helicopters', 'scooters']
    
    }[category.toLowerCase()] ?? [];
  }







  Future<Map<String, String>?> _fetchTopic(String topic) async {
    try {
      if (_imageCache.containsKey(topic)) {
        return _createSubcategoryItem(topic, topic);
      }

      final response = await http.get(
        Uri.parse('https://api.unsplash.com/search/photos?query=$topic&client_id=${UnsplashService.accessKey}&per_page=1'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['results'].isNotEmpty) {
          final imageUrl = data['results'][0]['urls']['regular'] as String;
          _imageCache[topic] = NetworkImage(imageUrl);
          return _createSubcategoryItem(topic, imageUrl);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching topic $topic: $e');
    }
    return _createSubcategoryItem(topic, fallbackImage);
  }

  Map<String, String> _createSubcategoryItem(String topic, String image) {
    return {
      'name': topic.replaceAll('-', ' ').toUpperCase(),
      'query': topic,
      'image': image,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Subcategories'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: subcategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorState();
          }
          return _buildGrid(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildLoadingState() => const Center(child: CircularProgressIndicator());

  Widget _buildErrorState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        const Text('Failed to load subcategories'),
        TextButton(
          onPressed: () => setState(() {}),
          child: const Text('Retry'),
        ),
      ],
    ),
  );

  Widget _buildGrid(List<Map<String, String>> items) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 1.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => _SubcategoryCard(item: items[index]),
      ),
    );
  }
}

class _SubcategoryCard extends StatelessWidget {
  final Map<String, String> item;

  const _SubcategoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () => _navigateToCategory(context),
        child: Stack(
          children: [
            _buildImage(),
            _buildOverlay(),
            _buildTitle(),
          ],
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PictureDisplayScreen(query: item['query']!),
      ),
    );
  }

  Widget _buildImage() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: CachedNetworkImage(
          cacheManager: _customCacheManager,
          imageUrl: item['image']!,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Text(
        item['name']!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey),
      ),
    );
  }
}