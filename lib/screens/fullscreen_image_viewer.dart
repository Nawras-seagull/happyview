import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:happy_view/services/pixabay_services.dart';
import 'package:happy_view/widgets/download_button.dart';
import 'package:happy_view/widgets/favorite_button.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
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
      final newImages = await PixabayService.fetchImages(
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
    Future<void> setWallpaper(String imageUrl) async {
    final status = await Permission.storage.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission denied")),
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(imageUrl));
      final Uint8List bytes = response.bodyBytes;

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/temp_wallpaper.jpg';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await WallpaperManagerFlutter().setWallpaper(
        file,
        WallpaperManagerFlutter.homeScreen,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wallpaper set successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to set wallpaper: $e")),
      );
    }
  }
/* 
Future<void> setWallpaper(String imageUrl) async {
  // Request permissions
  var status = await Permission.storage.request();
  if (!status.isGranted) {
    return;
  }

  try {
    // Download image
    final response = await http.get(Uri.parse(imageUrl));
    final Uint8List bytes = response.bodyBytes;

    // Save to temporary file
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/temp_wallpaper.jpg';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // Set wallpaper
    await WallpaperManagerFlutter().setWallpaper(
      file,
      WallpaperManagerFlutter.homeScreen,
    );
  } catch (e) {
    print("Error setting wallpaper: $e");
  }
} */
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change to your desired color
        ),
        title: Text(
            localizations.imageIndex(_currentIndex + 1, widget.images.length)),
        actions: [
          // Favorite button
          FavoriteButton(
            image: widget.images[_currentIndex],
          ),
          // Download button
          DownloadButton(
              imageUrl: widget.imageUrl, downloadUrl: widget.downloadUrl),
              ElevatedButton(
  onPressed: () async {
   String imageUrl = widget.images[_currentIndex]['urls']?['regular'] ?? widget.images[_currentIndex]['url'];
    await setWallpaper(imageUrl); // Replace with your actual image URL or path
  },
  child: Text("Set as Wallpaper"),
),
        ],
        
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          // Photo credit and info at the bottom
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildImageTitle(context, widget.images[_currentIndex]),
                    ),
                    SizedBox(width: 8.0),
                    _buildLikesCounter(context, widget.images[_currentIndex]),
                  ],
                ),
                SizedBox(height: 8.0),
                _buildPixabayAttribution(context, widget.images[_currentIndex]),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  // Build the title widget showing first three tags
  Widget _buildImageTitle(BuildContext context, Map<String, dynamic> image) {
    final String title = image['title'] ?? '';
    if (title.isEmpty) return SizedBox.shrink();
    
    // Split by commas and take first three tags
    final List<String> allTags = title.split(',');
    final String displayTags = allTags.take(3).join(', ').trim();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        displayTags,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  // Build the likes counter widget
  Widget _buildLikesCounter(BuildContext context, Map<String, dynamic> image) {
    final likes = image['likes'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite,
            color: Colors.red,
            size: 16.0,
          ),
          SizedBox(width: 4.0),
          Text(
            '$likes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  // Build the attribution widget at the bottom
  Widget _buildPixabayAttribution(BuildContext context, Map<String, dynamic> image) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        'Photo by ${image['photographer']} on Pixabay',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    );
  }
}