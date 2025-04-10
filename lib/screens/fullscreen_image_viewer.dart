import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happy_view/services/unsplash_attribution.dart';
import 'package:happy_view/services/unsplash_service.dart';
import 'package:happy_view/widgets/download_button.dart';
import '../l10n/app_localizations.dart';

class FullScreenImageView extends StatefulWidget {
  final String imageUrl;
  final String photographerName;
  final String photoLink;
  final String downloadUrl;
  final int initialIndex;
  final String query; // Add the query property
  final List<Map<String, dynamic>> images;

  const FullScreenImageView({
    super.key,
    required this.imageUrl,
    required this.photographerName,
    required this.photoLink,
    required this.initialIndex,
    required this.downloadUrl,
    required this.images,
    required this.query, // Add the query parameter
  });

  @override
  FullScreenImageViewState createState() => FullScreenImageViewState();
}

class FullScreenImageViewState extends State<FullScreenImageView> {
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

/*   Future<void> _handleDownload(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      await UnsplashDownloadService.triggerDownload(widget.downloadUrl);

      // Show a snackbar to confirm download
      /*  ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.downloadStarted),
          duration: const Duration(seconds: 2),
        ),
      ); */
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.downloadFailed),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } */

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar( iconTheme: IconThemeData(
    color: Colors.white, // Change to your desired color
  ),
         title: Text(
            localizations.imageIndex(_currentIndex + 1, widget.images.length)),
        actions: [
          
          DownloadButton(imageUrl: widget.imageUrl,
            downloadUrl: widget.downloadUrl),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
    /*     actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () async {
              // Trigger the existing _handleDownload method
             // await _handleDownload(context);

              // Trigger the DownloadButton functionality
              DownloadButton(imageUrl: widget.images[_currentIndex]['url']);
            },
            tooltip: localizations.download,
          ),
        ], */
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
                imageUrl: image['urls']?['regular'] ?? image['url'],
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                      child: SpinKitThreeInOut(
                    color: Color.fromARGB(255, 8, 127, 148),
                    size: 30.0,
                  )),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              );
            },
          ), 
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UnsplashAttribution.buildAttribution(
            context,
            widget.images[_currentIndex],
            textColor: Colors.white,
            fontSize: 16.0,
          ), 
              ]
            ),
            
           )

        ],
      ),
      backgroundColor: Colors.black,
    );
  }
  
}
