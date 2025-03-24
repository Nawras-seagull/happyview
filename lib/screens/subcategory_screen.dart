import 'dart:async';
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
}