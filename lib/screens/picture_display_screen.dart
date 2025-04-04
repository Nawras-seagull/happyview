import 'dart:async'; // For debounce
import 'dart:math'; // Import for random number generation
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:happy_view/services/unsplash_attribution.dart';
import 'package:happy_view/services/unsplash_service.dart.dart';
import 'package:happy_view/widgets/animated_panda.dart';
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
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final String _selectedSubcategory = 'All';
  Timer? _debounce; // For debouncing scroll events

  @override
  void initState() {
    super.initState();
    _fetchImages(randomizePage: true); // Fetch random images on screen load
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fetch images from Unsplash
  Future<void> _fetchImages({bool randomizePage = false}) async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate a random page number if randomizePage is true
      if (randomizePage) {
        final random = Random();
        _page =
            random.nextInt(50) + 1; // Assuming Unsplash has at least 50 pages
      }




      final newImages = await UnsplashService.fetchImages(
        widget.query,
        page: _page,
        subcategory: _selectedSubcategory == 'All' ? '' : _selectedSubcategory,
      );

      if (newImages.isEmpty) {
        setState(() {
          _hasMore = false;
        });
      } else {
        setState(() {
          _images.addAll(newImages);
          _page++;
        });

        // Shuffle the images locally (optional)
        _images.shuffle();
      }
    } catch (e) {
      _showErrorSnackbar('Failed to load images. Please try again.');
      if (kDebugMode) {
        print('Error fetching images: $e');
      }




      
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show error message in a Snackbar
 void _showErrorSnackbar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Retry',
        onPressed: _fetchImages,
      ),
    ),
  );
}

  // Debounced scroll listener
  void _onScroll() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _hasMore) {
        _fetchImages();
      }
    });
  }

  // Navigate to the full-screen image viewer
  void _openFullScreenImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: _images,
          initialIndex: index,
          query: widget.query,
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
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.7,
              ),
              itemCount: _images.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final image = _images[index];
                return GestureDetector(
                  onTap: () => _openFullScreenImage(index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: image['url'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                );
              },
            ),
          ),
            // The fun panda
    AnimatedPanda()
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
        localizations.imageIndex(_currentIndex + 1, widget.images.length)
      ),
      actions: [
        DownloadButton(imageUrl: widget.images[_currentIndex]['url']),
      ],
    ),
    body: Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            final image = widget.images[index];
            return InteractiveViewer(
              panEnabled: true,
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
        // Attribution positioned at the bottom
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: UnsplashAttribution.buildAttribution(
            context, 
            widget.images[_currentIndex],
          ),
        ),
      ],
    ),
  );
}
}