import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:happy_view/screens/fullscreen_image_viewer.dart';
import 'package:happy_view/screens/subcategory_screen.dart';
import 'package:http/http.dart' as http;
import 'settings_screen.dart';

// Top-level function for parsing JSON off the main thread
Map<String, dynamic> parseJson(String responseBody) {
  return json.decode(responseBody);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Define categories with translations
    final categories = [
      {
        'name': localizations.category_animals,
        'query': 'animals',
        'image': 'lib/assets/images/animals.png',
      },
      {
        'name': localizations.category_nature,
        'query': 'nature',
        'image': 'lib/assets/images/nature.png',
      },
      {
        'name': localizations.category_space,
        'query': 'space',
        'image': 'lib/assets/images/space.png',
      },
      {
        'name': localizations.category_food_drink,
        'query': 'food-drink',
        'image': 'lib/assets/images/science.png',
      },
      {
        'name': localizations.category_shapes,
        'query': 'shapes',
        'image': 'lib/assets/images/shapes.png',
      },
      {
        'name': localizations.category_vehicles,
        'query': 'vehicles',
        'image': 'lib/assets/images/vehicles.png',
      },
      {
        'name': localizations.category_architecture,
        'query': 'architecture',
        'image': 'lib/assets/images/architecture.png',
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'lib/assets/images/logo.png', // Path to your logo image
              height: 40.0,
            ),
            const SizedBox(width: 8.0),
            Text(localizations.appTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showVerificationDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Grid of Categories
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CategoryCard(
                  name: categories[index]['name']!,
                  query: categories[index]['query']!,
                  image: categories[index]['image']!,
                );
              },
            ),
          ),
          // Surprise Me! Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _showRandomPicture(context),
              child: Text(
                localizations.suprise, // Translate the name
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Improved random picture function with proper error handling and loading state
  void _showRandomPicture(BuildContext context) async {
    final random = Random();
    final topics = [
      'animals',
      'nature',
      'space',
      'food-drink',
      'shapes',
      'vehicles',
      'buildings'
    ];
    final randomTopic = topics[random.nextInt(topics.length)];
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
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
}

class CategoryCard extends StatelessWidget {
  final String name;
  final String image;
  final String query;

  const CategoryCard({
    super.key,
    required this.name,
    required this.image,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubcategoryScreen(category: query),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8.0),
              ),
              child: AspectRatio(
                aspectRatio: 13 / 8, // Adjust ratio as needed
                child: Image.asset(
                  image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name, // Translate the name
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Verification dialog function
void _showVerificationDialog(BuildContext context) {
  final random = Random();
  final num1 = random.nextInt(10);
  final num2 = random.nextInt(10);
  final correctAnswer = num1 + num2;
  final localizations = AppLocalizations.of(context)!;
  final TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(localizations.verification),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.whatIsSum(num1, num2)),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              if (int.tryParse(controller.text) == correctAnswer) {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizations.incorrect)),
                );
              }
            },
            child: Text(localizations.confirm),
          ),
        ],
      );
    },
  );
}