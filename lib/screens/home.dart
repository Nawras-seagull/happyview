import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:happy_view/screens/fullscreen_image_viewer.dart';
import 'package:happy_view/screens/subcategory_screen.dart';
import 'package:http/http.dart' as http;
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
   const HomeScreen({super.key});



 

/* 
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.hello,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                localizations.welcome,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Text(
                localizations.greeting('User'),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                localizations.itemCount(0),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                localizations.currentDate(DateTime.now()),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Item'),
                onPressed: () {
                  // Add item
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} */


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
    ];




    return Scaffold(
     
      appBar: AppBar(
        title: Text(localizations.appTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
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
              onPressed: () => showRandomPicture(context),
              child:  Text(localizations.suprise, // Translate the name
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ),
        ],
      ),
    );
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
              child: Image.asset(
                image,
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(((name)), // Translate the name
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
 
void showRandomPicture(BuildContext context) async {
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

  final response = await http.get(
    Uri.parse(
      'https://api.unsplash.com/photos/random?query=$randomTopic&client_id=rymj4kWDUWfggopViVtniGBy1FV6alObBnbHlVeWw6g',
    ),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final imageUrl = data['urls']['regular'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(imageUrl: imageUrl),
      ),
    );
  } else {
    // Handle error
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Failed to load image')));
  } 
}
 