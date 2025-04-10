import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:happy_view/screens/fullscreen_image_viewer.dart';
import 'package:happy_view/services/unsplash_service.dart';
import 'package:happy_view/widgets/animated_panda.dart';
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


    // Set the current query if provided
  if (widget.query != null) {
    _currentQuery = widget.query!;
  }

  // Fetch images from the Unsplash API
  _fetchImages();

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

        final random = Random();
        _page =
            random.nextInt(50) + 1; // Assuming Unsplash has at least 50 pages
      
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
        builder: (context) => FullScreenImageView(
          imageUrl: _images[index]['url'],
          photographerName: _images[index]['photographer'],
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
      SizedBox.expand( child:
    // Now the AnimatedPanda can be a direct child of Stack
         const Positioned(
         /*  bottom: -100,
          left: 0,
          right: 0,  */
          child: AnimatedPanda(),
        ),
      ),
      ],
    ),
  );
}
}
