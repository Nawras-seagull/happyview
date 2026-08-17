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
  late final SubcategoryService _service = SubcategoryService();
  late Future<List<Map<String, String>>> _subcategories;
  String? _selectedTopic;
  Locale? _lastLocale;
  static const String _fallbackImage = 'lib/assets/images/panda_peek.webp';

  @override
  void initState() {
    super.initState();
    // no fetch here — didChangeDependencies handles the first load
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = Localizations.localeOf(context);
    if (_lastLocale != currentLocale) {
      _lastLocale = currentLocale;
      if (_lastLocale != null) {
        _service.clearCache(); // only clear when locale actually changed
      }
      _loadSubcategories();
    }
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
        return RepaintBoundary(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UnifiedPictureScreen(query: item['query'] ?? ''),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withAlpha(50),
                        BlendMode.darken,
                      ),
                      child: (() {
                        final imagePath = item['image'] ?? _fallbackImage;
                        final isAssetImage =
                            imagePath.startsWith('lib/assets/') ||
                                imagePath.startsWith('assets/');

                        if (isAssetImage) {
                          return Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                            cacheWidth: 400,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        }

                        return CachedNetworkImage(
                          imageUrl: imagePath,
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
                          memCacheWidth: 400,
                          memCacheHeight: 400,
                          cacheManager: _customCacheManager,
                          height: double.infinity,
                          width: double.infinity,
                        );
                      })(),
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
          ),
        );
      },
    ),
  );
}
}

