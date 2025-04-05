import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:happy_view/screens/subcategory_screen.dart';
import 'package:happy_view/screens/search_screen.dart';
import 'package:happy_view/widgets/categories.dart';
import 'package:happy_view/widgets/random_picture_helper.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:happy_view/widgets/search_bar.dart';
import 'settings_screen.dart';
import 'search_screen.dart';

// Top-level function for parsing JSON off the main thread
Map<String, dynamic> parseJson(String responseBody) {
  return json.decode(responseBody);
}

class CategoryTile extends StatelessWidget {
  final String name;
  final String image;
  final String query;
  final VoidCallback onTap;

  const CategoryTile(
      {required this.name,
      required this.image,
      required this.query,
      required this.onTap,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              image, height: 150, width: 150,
              fit: BoxFit.cover, // Set cache dimensions to reduce memory usage
              cacheWidth: 150, // Match the widget's width
              cacheHeight: 150,
            ),
          ),
          const SizedBox(height: 2),
          Text(name,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 9, 45, 42))),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<dynamic> _searchResults = [];

  void _handleSearch(List<dynamic> results) {
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Define categories with translations
    final categories = getCategories(AppLocalizations.of(context)!);

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
          // Search Bar
          FunSearchBar(onSearch: (List<dynamic> results) {
            // Navigate to the SearchScreen and pass the search results
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(searchResults: results),
              ),
            );
          }),
          
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
                final category = categories[index];

                return CategoryTile(
                  name: category['name'],
                  image: category['image'],
                  query: category['query'],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            SubcategoryScreen(category: category['query'])),
                  ),
                );
              },
            ),
          ),
          // Surprise Me! Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                // Play sound
                await _audioPlayer.play(AssetSource('sounds/yay.wav'));

                // Then show the picture
                showRandomPicture(context);
              },
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
}
