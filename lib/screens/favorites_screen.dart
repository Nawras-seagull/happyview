import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happy_view/services/favorites_service.dart';
import '../l10n/app_localizations.dart';
import 'package:happy_view/screens/fullscreen_image_viewer.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  FavoritesScreenState createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    
    // Listen to changes in favorites
    _favoritesService.favoritesNotifier.addListener(_loadFavorites);
  }

  @override
  void dispose() {
    _favoritesService.favoritesNotifier.removeListener(_loadFavorites);
    super.dispose();
  }

  void _loadFavorites() {
    setState(() {
      _favorites = _favoritesService.getAllFavorites();
    });
  }

  void _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clearFavorites),
        content: Text(AppLocalizations.of(context)!.clearFavoritesConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.clear),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _favoritesService.clearAllFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.clear),
        ),
      );
    }
  }

  void _navigateToFullScreen(int index) {
    if (_favorites.isEmpty) return;
    
    final image = _favorites[index];
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(
          imageUrl: image['url'] ?? '',
          photographerName: image['photographer'] ?? '',
          photoLink: image['photoLink'] ?? '',
          initialIndex: index,
          downloadUrl: image['download'] ?? '',
          images: _favorites,
          query: 'favorites', // Not used for actual search but needed by the widget
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.favorites),
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllFavorites,
              tooltip: localizations.clearFavorites,
            ),
        ],
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.noFavorites,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: Text(localizations.browseImages),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final image = _favorites[index];
                return _buildImageCard(image, index);
              },
            ),
    );
  }

  Widget _buildImageCard(Map<String, dynamic> image, int index) {
    return GestureDetector(
      onTap: () => _navigateToFullScreen(index),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            CachedNetworkImage(
              imageUrl: image['url'] ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: SpinKitThreeInOut(
                  color: const Color.fromARGB(255, 8, 127, 148),
                  size: 30.0,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            
            // Image title overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                color: Colors.black.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title (first 3 tags)
                    Expanded(
                      child: _buildImageTitle(image),
                    ),
                    
                    // Likes count
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 16.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '${image['likes'] ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTitle(Map<String, dynamic> image) {
    final String title = image['title'] ?? '';
    if (title.isEmpty) return const SizedBox.shrink();
    
    // Split by commas and take first three tags
    final List<String> allTags = title.split(',');
    final String displayTags = allTags.take(3).join(', ').trim();
    
    return Text(
      displayTags,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12.0,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}