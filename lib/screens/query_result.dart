import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:happy_view/services/unsplash_attribution.dart';
import 'package:happy_view/services/unsplash_service.dart.dart';
import 'package:happy_view/widgets/animated_panda.dart';
import 'package:happy_view/widgets/download_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UnifiedPictureScreen extends StatefulWidget {
  final String? query; // For subcategory display
  final List<dynamic>? initialResults; // For search results

  const UnifiedPictureScreen({
    super.key,
    this.query,
    this.initialResults,
  }) : assert(query != null || initialResults != null, 
           'Either query or initialResults must be provided');

  @override
  UnifiedPictureScreenState createState() => UnifiedPictureScreenState();
}
////////////////////////
class UnifiedPictureScreenState extends State<UnifiedPictureScreen> {
  final List<Map<String, dynamic>> _images = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();

    // In query_result.dart
if (widget.initialResults != null) {
  // Convert search results to our image format
  _images.addAll(widget.initialResults!.map((result) => {
        'url': result['urls']['regular'],
        'user': result['user'],
        'links': result['links'],
        'location': result['location'] ?? '',

      }));
  
  // Set the current query
  if (widget.query != null) {
    _currentQuery = widget.query!;
  }
}
    
     else if (widget.query != null) {
      _currentQuery = widget.query!;
      _fetchImages();
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchImages() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newImages = await UnsplashService.fetchImages(
        _currentQuery,
        page: _page,
      );

      if (newImages.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        setState(() {
          _images.addAll(newImages);
          _page++;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to load images. Please try again.');
      if (kDebugMode) print('Error fetching images: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasMore &&
        !_isLoading) {
      _fetchImages();
    }
  }

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

  void _openFullScreenImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: _images,
          initialIndex: index,
          query: _currentQuery,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.query ?? 'Search Results'),
      ),
       body: Stack(  // Changed from Column to Stack
      children: [
        Column(
        children: [
          Expanded(
            child: _images.isEmpty && !_isLoading
                ? Center(
                    child: Text(
                      'No images found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : GridView.builder(
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
                        return const Center(
                          child: SpinKitThreeInOut(
                            color: Color.fromARGB(255, 8, 127, 148),
                            size: 30.0,
                          ),
                        );
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
                                const Center(child: SpinKitThreeInOut(
                                  color: Color.fromARGB(255, 8, 127, 148),
                                  size: 30.0,
                                )),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      );
                    },
                  ),
                  
          ),
     
        ],
      ),
    // Now the AnimatedPanda can be a direct child of Stack
         const Positioned(
          bottom: -1,
          left: 0,
          right: 0, 
          child: AnimatedPanda(),
        ),
      ],
    ),
  );
}
}
// FullScreenImageViewer 
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
  FullScreenImageViewerState createState() => FullScreenImageViewerState();}

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
          localizations.imageIndex(_currentIndex + 1, widget.images.length),
        ),
        actions: [
          DownloadButton(imageUrl: widget.images[_currentIndex]['url'],
                          location: widget.images[_currentIndex]['location'],
                          ),
                          
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
                  placeholder: (context, url) => Center(
                    child: SpinKitThreeInOut(
                      color: Color.fromARGB(255, 8, 127, 148),
                      size: 30.0,
                    ),
                  ),
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
