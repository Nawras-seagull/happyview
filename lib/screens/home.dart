import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:happy_view/widgets/sound_effect_handler.dart';
import '../l10n/app_localizations.dart';
import 'package:happy_view/screens/query_result.dart';
import 'package:happy_view/screens/subcategory_screen.dart';
import 'package:happy_view/widgets/categories.dart';
import 'package:happy_view/widgets/random_picture_helper.dart';
import 'package:happy_view/widgets/search_bar.dart';
import 'settings_screen.dart';

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

  @override
  void initState() {
    super.initState();

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

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Play click sound without blocking
        _playSound();
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
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.image,
                  fit: BoxFit.cover,
                  width: double.infinity, // Take full width of parent
                    // Preload and cache images
                  cacheWidth: 300, // Add reasonable cache width
                  gaplessPlayback: true, // Prevent flickering on reload
               ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 9, 45, 42),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
    // Move sound playing to a separate method to keep build method clean
  void _playSound() {
    // Use a non-blocking approach to play sounds
    SoundEffectHandler().playClick();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>with AutomaticKeepAliveClientMixin {
  // Categories will be loaded lazily
  late List<Map<String, dynamic>> _categories;
  bool _categoriesLoaded = false;

  @override
    bool get wantKeepAlive => true; // Keep state when navigating
  @override

  void initState() {
    super.initState();
  // Load categories in a deferred way
    _loadCategories();
    
    // Preload assets in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAssets();
    });
  }
    Future<void> _loadCategories() async {
    // Use compute to move this work off the main thread if necessary
    await Future.delayed(Duration.zero); // Yield to the main thread
    
    if (mounted) {
      setState(() {
        _categoriesLoaded = true;
      });
    }
  }
Future<void> _preloadAssets() async {
    // Preload sound effects
    SoundEffectHandler().playYay();
    
    // We could also preload some initial images here
    // but be careful not to overload memory
  }
/*   @override
  void dispose() {
    //  _audioPlayer.dispose();
    super.dispose();
  } */

  @override
  Widget build(BuildContext context) {
        super.build(context); // Required for AutomaticKeepAliveClientMixin

    final localizations = AppLocalizations.of(context)!;

    // Define categories with translations
/*     final categories = getCategories(AppLocalizations.of(context)!);
 */

    // Only load categories when needed
    if (!_categoriesLoaded) {
      _categories = [];
    } else {
      _categories = getCategories(localizations);
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'lib/assets/images/panda_peek.png', // Path to your logo image
              height: 40.0,
                width: 40.0, // Specify width to avoid layout shifts
              cacheWidth: 80, // 2x for high-DPI displays
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
/////////////////// Search Bar////////////////////////
                   FunSearchBar(onSearch: _handleSearch),

          ///////////////////End of Search Bar////////////////////////

            // Grid of Categories - Using lazy loading
          Expanded(
            child: _categoriesLoaded 
                ? _buildCategoriesGrid()
                : const Center(child: CircularProgressIndicator()),
          ),
           // Surprise Me! Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _handleSurpriseMe(context),
              child: Text(
                localizations.suprise,
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
// Extracted methods to make build method cleaner
  Widget _buildCategoriesGrid() {
    return GridView.builder(
      key: const PageStorageKey('categories_grid'),
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.85,
      ),
      itemCount: _categories.length,
      // Use caching for grid items
      addAutomaticKeepAlives: true,
      itemBuilder: (context, index) {
        final category = _categories[index];

        return CategoryTile(
          name: category['name'],
          image: category['image'],
          query: category['query'],
          onTap: () => _navigateToSubcategory(context, category),
        );
      },
    );
  }
  
  // Navigation handler extracted to a method
  void _navigateToSubcategory(BuildContext context, Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubcategoryScreen(category: category['query']),
      ),
    );
  }
  
  // Search handler extracted to a method
  void _handleSearch(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedPictureScreen(
          query: query,
        ),
      ),
    );
  }
  
  // Surprise me handler
  void _handleSurpriseMe(BuildContext context) {
    // Play sound in a non-blocking way
    SoundEffectHandler().playYay();
    
    // Show random picture
    showRandomPicture(context);
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
