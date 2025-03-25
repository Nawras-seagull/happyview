import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:happy_view/services/unsplash_service.dart.dart';
import 'package:happy_view/widgets/download_button.dart';

class PictureDisplayScreen extends StatefulWidget {
  final String query;

  const PictureDisplayScreen({super.key, required this.query});

  @override
  PictureDisplayScreenState createState() => PictureDisplayScreenState();
}

class PictureDisplayScreenState extends State<PictureDisplayScreen> {
  final List<Map<String, dynamic>> _images = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true; // Track if there are more images to load
  final ScrollController _scrollController = ScrollController();

  final String _selectedSubcategory = 'All'; // Default subcategory

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch images from Unsplash
  Future<void> _fetchImages() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newImages = await UnsplashService.fetchImages(
        widget.query,
        page: _page,
        subcategory: _selectedSubcategory == 'All' ? '' : _selectedSubcategory,
      );
      setState(() {
        if (newImages.isEmpty) {
          _hasMore = false; // No more images to load
        } else {
          _images.addAll(newImages);
          _page++;
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching images: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load more images when the user scrolls to the bottom
  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasMore) {
      _fetchImages();
    }
  }

  // Handle subcategory selection
  /* void _onSubcategorySelected(String subcategory) {
    setState(() {
      _selectedSubcategory = subcategory;
      _images.clear(); // Clear existing images
      _page = 1; // Reset page counter
      _hasMore = true; // Reset hasMore flag
    });
    _fetchImages(); // Fetch images for the new subcategory
  }
 */
  // Navigate to the full-screen image viewer
  void _openFullScreenImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: _images,
          initialIndex: index,
          query: widget.query, // Pass the query to the FullScreenImageViewer
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.query),
      ),
      body: Column(
        children: [
          // Image Grid
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns
                crossAxisSpacing: 16.0, // Spacing between columns
                mainAxisSpacing: 16.0, // Spacing between rows
                childAspectRatio:
                    0.7, // Adjust the aspect ratio for Pinterest-like layout
              ),
              itemCount: _images.length +
                  (_hasMore ? 1 : 0), // Add 1 for the loading indicator
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return Center(
                      child:
                          CircularProgressIndicator()); // Show loading indicator at the bottom
                }
                final image = _images[index];
                return GestureDetector(
                  onTap: () => _openFullScreenImage(
                      index), // Open full-screen image viewer
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: image['url'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Full-Screen Image Viewer
class FullScreenImageViewer extends StatefulWidget {
  final List<Map<String, dynamic>> images;
  final int initialIndex;
  final String query; // Add the query property

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.query, // Add the query parameter
  });

  @override
  FullScreenImageViewerState createState() => FullScreenImageViewerState();
}

class FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    setState(() {
      _currentIndex = _pageController.page!.round();
    });

    // Fetch more images if the user reaches the end of the list
    if (_currentIndex == widget.images.length - 1 && !_isLoadingMore) {
      _fetchMoreImages();
    }
  }

  Future<void> _fetchMoreImages() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newImages = await UnsplashService.fetchImages(
        widget.query, // Use the query property
        page: (_currentIndex ~/ 20) + 2, // Calculate the next page number
      );

      if (newImages.isNotEmpty) {
        setState(() {
          widget.images.addAll(newImages);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching more images: $e');
      }
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            localizations.imageIndex(_currentIndex + 1, widget.images.length)),
        actions: [
          DownloadButton(imageUrl: widget.images[_currentIndex]['url']),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final image = widget.images[index];
          return InteractiveViewer(
            panEnabled: true, // Allow zooming and panning
            minScale: 1.0,
            maxScale: 3.0,
            child: CachedNetworkImage(
              imageUrl: image['url'],
              fit: BoxFit.contain,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          );
        },
      ),
    );
  }
}
