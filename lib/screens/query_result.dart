import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:happy_view/l10n/app_localizations.dart';
import 'package:happy_view/screens/fullscreen_image_viewer.dart';
import 'package:happy_view/services/pixabay_services.dart';
import 'package:happy_view/widgets/animated_panda.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happy_view/widgets/subcategory_data.dart';

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

    // Handle initial data if provided
    if (widget.initialResults != null && widget.initialResults!.isNotEmpty) {
      setState(() {
        _images.addAll(widget.initialResults!
            .map((item) => item as Map<String, dynamic>)
            .toList());
      });
    }
    // Set the current query if provided
    if (widget.query != null) {
      _currentQuery = widget.query!;
      // Only fetch if we don't have initial results
      if (widget.initialResults == null || widget.initialResults!.isEmpty) {
        // Add a small delay to ensure the widget is fully built
        Future.delayed(Duration.zero, () {
          _fetchImages();
        });
      }
    }

    // Add a listener to the scroll controller
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchImages({bool randomizePage = false}) async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
// Consider adding a debug print here to verify the query
    if (kDebugMode) {
      print('Fetching images for query: $_currentQuery (Page: $_page)');
    }
    if (randomizePage) {
      final random = Random();
      _page = random.nextInt(30) + 1; // Random page between 1 and 50
    }
    try {
      final newImages = await PixabayService.fetchImages(
        _currentQuery,
        page: _page,
      );

      if (newImages.isEmpty) {
        setState(() => _hasMore = false);
        if (_images.isEmpty) {
          _showErrorSnackbar(
              'No images found for "$_currentQuery". Try another search.');
        }
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
          label: AppLocalizations.of(context)!.loadErrorRetry,
          onPressed: _fetchImages,
        ),
      ),
    );
  }

  void _openFullScreenImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(
          imageUrl: _images[index]['url'] ?? _images[index]['webformatURL'],
          photographerName:
              _images[index]['photographer'] ?? ['user'] ?? 'Unknown',
          photoLink: _images[index]['photoLink'],
          downloadUrl: _images[index]['download'], // Pass the download URL
          images: _images, // Pass the list of images
          initialIndex: index,
          query: _currentQuery, // Pass the query
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final translatedQuery = SubcategoryData.getTranslatedTopic(
        localizations, widget.query ?? localizations.searchResults);

    return Scaffold(
      appBar: AppBar(
        title: Text(translatedQuery),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _images.clear();
                _page = 1;
                _hasMore = true;
              });
              _fetchImages(randomizePage: true);
            },
            tooltip: 'Retry loading images',
          ),
        ],
      ),
      body: SafeArea(
        // <-- Add SafeArea here
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _images.isEmpty && !_isLoading
                      ? Center(
                          child: Text(
                            localizations.noImagesFound,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: _images.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _images.length) {
                              return _hasMore
                                  ? const Center(
                                      child: SpinKitThreeInOut(
                                        color: Color.fromARGB(255, 8, 127, 148),
                                        size: 30.0,
                                      ),
                                    )
                                  : Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.photo_library_outlined,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              localizations.endOfResults,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _page = 1;
                                                  _hasMore = true;
                                                });
                                                _fetchImages(
                                                    randomizePage: true);
                                              },
                                              child: Text(
                                                  localizations.exploreMore),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                            }
                            final image = _images[index];
                            return GestureDetector(
                              onTap: () => _openFullScreenImage(index),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  imageUrl: image['url'] ?? image['previewURL'],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                      child: SpinKitThreeInOut(
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
            const Positioned(
              child: AnimatedPanda(),
            ),
          ],
        ),
      ), // <-- End SafeArea
    );
  }
}
