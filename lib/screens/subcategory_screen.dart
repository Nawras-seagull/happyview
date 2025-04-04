import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:happy_view/services/unsplash_service.dart.dart';
import 'package:http/http.dart' as http;
import 'picture_display_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  static const String _fallbackImage = 'https://via.placeholder.com/300';

  late Future<List<Map<String, String>>> _subcategories;
  String? _selectedTopic;

  @override
  void initState() {
    super.initState();
    _loadSubcategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categoryCache.clear();
    _loadSubcategories();
  }

  void _loadSubcategories() {
    setState(() {
      _subcategories = _getSubcategories(context, widget.category).catchError((error) {
        if (kDebugMode) print('Error loading subcategories: $error');
        return <Map<String, String>>[];
      });
    });
  }

Future<List<Map<String, String>>> _getSubcategories(BuildContext context, String category) async {
  if (_categoryCache.containsKey(category)) {
    return _categoryCache[category]!;
  }
  
  final topics = _getCategoryTopics(category);
  final results = await Future.wait(
    topics.map((topic) => _fetchTopic(context, topic)),
  );
  final subcategories = results.whereType<Map<String, String>>().toList();
  _categoryCache[category] = subcategories;
  return subcategories;
}
  Map<String, List<String>> get _categoryTopicsMap => {
    'animals': ['mammals', 'birds', 'reptiles', 'sea-creatures', 'insects', 'amphibians', 
                'wildlife', 'pets', 'farm-animals', 'baby-animals'],
    'nature': ['trees', 'flower', 'forests', 'mountains', 'oceans', 'snow', 'sunsets', 
               'waterfalls', 'rivers', 'lakes', 'leaf'],
    'space': ['planets', 'stars', 'galaxies', 'astronauts'],
    'architecture': ['buildings', 'bridges', 'skyscrapers', 'houses', 'furniture', 
                     'exteriors', 'landmarks', 'monuments', 'towers', 'castles'],
    'food-drink': ['fruits', 'vegetables', 'desserts', 'beverages', 'fast-food', 
                   'seafood', 'meat', 'dairy', 'baked-goods', 'healthy-food'],
    'shapes': ['circles', 'squares', 'triangles', 'rectangles', 'hexagons', 
               'hearts', 'spirals', 'diamonds', 'ovals'],
    'vehicles': ['cars', 'motorcycles', 'trucks', 'bicycles', 'buses', 'trains', 
                 'airplanes', 'boats', 'helicopters', 'scooters', 'excavators'],
  };

  List<String> _getCategoryTopics(String category) {
    return _categoryTopicsMap[category.toLowerCase()] ?? [];
  }

  Future<Map<String, String>?> _fetchTopic(BuildContext context, String topic) async {
    try {
      if (_imageCache.containsKey(topic)) {
        return _createSubcategoryItem(context, topic, topic);
      }

      final response = await http.get(Uri.parse(
        'https://api.unsplash.com/search/photos?query=$topic&client_id=${UnsplashService.accessKey}&per_page=1'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['results'].isNotEmpty) {
          final imageUrl = data['results'][0]['urls']['regular'] as String;
          _imageCache[topic] = NetworkImage(imageUrl);
          return _createSubcategoryItem(context, topic, imageUrl);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching topic $topic: $e');
    }
    return _createSubcategoryItem(context, topic, _fallbackImage);
  }

  Map<String, String> _createSubcategoryItem(BuildContext context, String topic, String image) {
    return {
      'name': _getTranslatedTopic(context, topic),
      'query': topic,
      'image': image,
    };
  }

  String _getTranslatedTopic(BuildContext context, String topic) {
    final localizations = AppLocalizations.of(context);
    final translations = _getTranslationMap(localizations);
    return translations[topic] ?? topic.replaceAll('-', ' ').toUpperCase();
  }

  Map<String, String?> _getTranslationMap(AppLocalizations? localizations) {
    return {
      'mammals': localizations?.mammals,
      'birds': localizations?.birds,
      'reptiles': localizations?.reptiles,
      'sea-creatures': localizations?.seaCreatures,
      'insects': localizations?.insects,
      'amphibians': localizations?.amphibians,
      'wildlife': localizations?.wildlife,
      'pets': localizations?.pets,
      'farm-animals': localizations?.farmAnimals,
      'baby-animals': localizations?.babyAnimals,
      'trees': localizations?.trees,
      'flower': localizations?.flower,
      'forests': localizations?.forests,
      'mountains': localizations?.mountains,
      'oceans': localizations?.oceans,
      'snow': localizations?.snow,
      'sunsets': localizations?.sunsets,
      'waterfalls': localizations?.waterfalls,
      'rivers': localizations?.rivers,
      'lakes': localizations?.lakes,
      'leaf': localizations?.leaf,
      'planets': localizations?.planets,
      'stars': localizations?.stars,
      'galaxies': localizations?.galaxies,
      'astronauts': localizations?.astronauts,
      'buildings': localizations?.buildings,
      'bridges': localizations?.bridges,
      'skyscrapers': localizations?.skyscrapers,
      'houses': localizations?.houses,
      'furniture': localizations?.furniture,
      'exteriors': localizations?.exteriors,
      'landmarks': localizations?.landmarks,
      'monuments': localizations?.monuments,
      'towers': localizations?.towers,
      'castles': localizations?.castles,
      'fruits': localizations?.fruits,
      'vegetables': localizations?.vegetables,
      'desserts': localizations?.desserts,
      'beverages': localizations?.beverages,
      'fast-food': localizations?.fastFood,
      'seafood': localizations?.seafood,
      'meat': localizations?.meat,
      'dairy': localizations?.dairy,
      'baked-goods': localizations?.bakedGoods,
      'healthy-food': localizations?.healthyFood,
      'circles': localizations?.circles,
      'squares': localizations?.squares,
      'triangles': localizations?.triangles,
      'rectangles': localizations?.rectangles,
      'hexagons': localizations?.hexagons,
      'hearts': localizations?.hearts,
      'spirals': localizations?.spirals,
      'diamonds': localizations?.diamonds,
      'ovals': localizations?.ovals,
      'cars': localizations?.cars,
      'motorcycles': localizations?.motorcycles,
      'trucks': localizations?.trucks,
      'bicycles': localizations?.bicycles,
      'buses': localizations?.buses,
      'trains': localizations?.trains,
      'airplanes': localizations?.airplanes,
      'boats': localizations?.boats,
      'helicopters': localizations?.helicopters,
      'scooters': localizations?.scooters,
      'excavators': localizations?.excavators,
    };
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final category = widget.category;

    return Scaffold(
      appBar: AppBar(
        title: Text('$category ${localizations?.subcategories ?? 'Subcategories'}'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
       //   _buildTopicFilter(context, category, localizations),
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: _subcategories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return _buildErrorState();
                }
                return _buildGrid(snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

/*   Widget _buildTopicFilter(BuildContext context, String category, AppLocalizations? localizations) {
    final topics = _getCategoryTopics(category);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: topics.map((topic) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_getTranslatedTopic(context, topic)),
                selected: _selectedTopic == topic,
                onSelected: (selected) {
                  setState(() {
                    _selectedTopic = selected ? topic : null;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
 */
  Widget _buildErrorState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)?.loadError ?? 'Failed to load subcategories'),
        TextButton(
          onPressed: _loadSubcategories,
          child: Text(AppLocalizations.of(context)?.loadErrorRetry ?? 'Retry'),
        ),
      ],
    ),
  );

  Widget _buildGrid(List<Map<String, String>> items) {
    final filteredItems = _selectedTopic != null
        ? items.where((item) => item['query'] == _selectedTopic).toList()
        : items;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) => _SubcategoryCard(item: filteredItems[index]),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToPictureScreen(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),
            _buildOverlay(),
            _buildTitle(),
          ],
        ),
      ),
    );
  }

  void _navigateToPictureScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PictureDisplayScreen(query: item['query']!),
      ),
    );
  }

  Widget _buildImage() {
    return CachedNetworkImage(
      cacheManager: _customCacheManager,
      imageUrl: item['image']!,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );
  }

  Widget _buildOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          item['name']!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const ColoredBox(
      color: Colors.grey,
      child: Center(
        child: Icon(Icons.image, size: 40, color: Colors.white),
      ),
    );
  }
}