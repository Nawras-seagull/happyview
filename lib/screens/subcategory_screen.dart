// subcategory_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happy_view/providers/subcategory_provider.dart';
import 'package:happy_view/screens/query_result.dart';
import '../l10n/app_localizations.dart';
import 'package:happy_view/widgets/subcategory_data.dart';

final _customCacheManager = CacheManager(
  Config(
    'happyViewCache',
    stalePeriod: const Duration(seconds: 7),
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
  late final SubcategoryService _service = SubcategoryService();
  late Future<List<Map<String, String>>> _subcategories;
  String? _selectedTopic;
  static const String _fallbackImage = 'lib/assets/images/logo.png';

  @override
  void initState() {
    super.initState();
    _loadSubcategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service.clearCache();
    _loadSubcategories();
  }

  void _loadSubcategories() {
    setState(() {
      _subcategories = _service
          .getSubcategories(context, widget.category)
          .catchError((error) {
        if (kDebugMode) print('Error loading subcategories: $error');
        return <Map<String, String>>[];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final category = widget.category;
    final translatedCategory =
        SubcategoryData.getTranslatedCategory(localizations, category);

    return Scaffold(
      appBar: AppBar(
        title: Text(translatedCategory),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SafeArea(
        // <-- Add SafeArea here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: _subcategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: SpinKitThreeInOut(
                      color: Color.fromARGB(255, 8, 127, 148),
                      size: 30.0,
                    ));
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
      ), // <-- End SafeArea
    );
  }

  Widget _buildErrorState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)?.loadError ??
                'Failed to load subcategories'),
            TextButton(
              onPressed: _loadSubcategories,
              child:
                  Text(AppLocalizations.of(context)?.loadErrorRetry ?? 'Retry'),
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
          childAspectRatio: 0.9,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UnifiedPictureScreen(query: item['query'] ?? ''),
                ),
              );
            }, //////////////////////////////
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                      bottom: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      // imageUrl: 'lib/assets/images/birds.jpg',
                      imageUrl: item['image'] ?? _fallbackImage,
                      placeholder: (context, url) => const Center(
                        child: SpinKitThreeInOut(
                          color: Color.fromARGB(255, 8, 127, 148),
                          size: 30.0,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                      ),
                      fit: BoxFit.cover,
                      cacheManager: _customCacheManager,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                        bottom: Radius.circular(16),
                      ),
                      color: Colors.black.withAlpha(50),
                    ),
                  ),
                  Positioned(
                    left: 8.0,
                    bottom: 8.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Text(
                        item['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
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
  }
}
