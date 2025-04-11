import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:happy_view/widgets/sound_effect_handler.dart';
import '../l10n/app_localizations.dart';
import 'package:happy_view/screens/query_result.dart';
import 'package:happy_view/screens/subcategory_screen.dart';
import 'package:happy_view/widgets/categories.dart';
import 'package:happy_view/widgets/random_picture_helper.dart';
//import 'package:audioplayers/audioplayers.dart';
import 'package:happy_view/widgets/search_bar.dart';
import 'settings_screen.dart';
import 'package:flutter/foundation.dart';
/////////////////////
///////////////////
// Top-level function for parsing JSON off the main thread
Map<String, dynamic> parseJson(String responseBody) {
  return json.decode(responseBody);
}

// Use compute to offload JSON parsing
Future<Map<String, dynamic>> parseJsonInBackground(String responseBody) async {
  return await compute(parseJson, responseBody);
}

class CategoryTile extends StatefulWidget {
  final String name;
  final String image;
  final String query;
  final VoidCallback onTap;

  const CategoryTile({
    required this.name,
    required this.image,
    required this.query,
    required this.onTap,
    super.key,
  });

  @override
  CategoryTileState createState() => CategoryTileState();
}

class CategoryTileState extends State<CategoryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
//    final AudioPlayer _audioPlayer2 = AudioPlayer();

  //////////////////
  ////////////
  

  @override
  void initState() {
    super.initState();
 //   _audioPlayer2.setSource(AssetSource('sounds/click.mp3'));

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Define the scale animation (zoom in effect)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Define the rotation animation (wiggle effect)
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
       // Set up listener to reset the player when sound finishes
  //  _audioPlayer2.onPlayerComplete.listen((event) {
    //  _audioPlayer2.setSource(AssetSource('sounds/click.mp3'));

  //  });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
 //   _audioPlayer2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()  {  // _audioPlayer2.seek(Duration.zero);
              //  _audioPlayer2.resume();
                 // Play click sound without blocking
        SoundEffectHandler().playClick();
        widget.onTap(); // Call the onTap function passed from the parent
  
              },
      onLongPress: () {
        _controller.repeat(reverse: true); // Start the animation
      },
      onLongPressUp: () {
        _controller.reset(); // Reset the animation when the press is released
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            Expanded(child:
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.image,
               
                fit: BoxFit.cover,
                  width: double.infinity,  // Take full width of parent

              ),
            ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 9, 45, 42),
              ),
                  textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
 // final AudioPlayer _audioPlayer = AudioPlayer();

 @override
  void initState() {
    super.initState();
    
    // Initialize prefetching when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeImagePrefetching(context);
    });
    // Set up audio player with initial source
   // _audioPlayer.setSource(AssetSource('sounds/yay.wav'));
    
    // Set up listener to reset the player when sound finishes
   // _audioPlayer.onPlayerComplete.listen((event) {
    //  _audioPlayer.setSource(AssetSource('sounds/yay.wav'));

   // });
  
    }
  @override
  void dispose() {
  //  _audioPlayer.dispose();
    super.dispose();
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
              'lib/assets/images/panda_peek.png', // Path to your logo image
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
FunSearchBar(onSearch: (List<dynamic> results, String query) {
  // Navigate to the SearchScreen with both search results and the query
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UnifiedPictureScreen(
        initialResults: results,
        query: query,  // Now passing the query from FunSearchBar
      ),
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
                childAspectRatio: 0.85, // Adjust this value to control the height/width ratio

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
              onPressed: ()  {
               // Reset to beginning and play sound
           //     _audioPlayer.seek(Duration.zero);
            //    _audioPlayer.resume();
                 SoundEffectHandler().playYay();
                // Show random picture from our categories
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
