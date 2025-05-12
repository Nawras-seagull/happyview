import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'pixabay_favorites';
  
  // Singleton pattern
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  // Cached favorites for quick access
  final Set<int> _favoriteIds = {};
  final Map<int, Map<String, dynamic>> _favoriteImages = {};
  
  // Stream controller to notify listeners of changes
  final ValueNotifier<Set<int>> favoritesNotifier = ValueNotifier<Set<int>>({});

  // Initialize favorites from storage
  Future<void> initialize() async {
    await _loadFavorites();
  }

  // Check if an image is favorited
  bool isFavorite(int imageId) {
    return _favoriteIds.contains(imageId);
  }

  // Get all favorite images
  List<Map<String, dynamic>> getAllFavorites() {
    return _favoriteImages.values.toList();
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(Map<String, dynamic> image) async {
    final int imageId = image['id'];
    
    if (_favoriteIds.contains(imageId)) {
      // Remove from favorites
      _favoriteIds.remove(imageId);
      _favoriteImages.remove(imageId);
    } else {
      // Add to favorites
      _favoriteIds.add(imageId);
      _favoriteImages[imageId] = image;
    }
    
    // Update storage
    await _saveFavorites();
    
    // Notify listeners
    favoritesNotifier.value = Set.from(_favoriteIds);
    
    // Return new state
    return isFavorite(imageId);
  }

  // Load favorites from storage
  Future<void> _loadFavorites() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_favoritesKey);
      
      if (favoritesJson != null) {
        final Map<String, dynamic> data = json.decode(favoritesJson);
        
        // Load favorite IDs
        final List<dynamic> ids = data['ids'] ?? [];
        _favoriteIds.clear();
        _favoriteIds.addAll(ids.map((id) => id as int));
        
        // Load favorite images
        final Map<String, dynamic> images = data['images'] ?? {};
        _favoriteImages.clear();
        images.forEach((key, value) {
          _favoriteImages[int.parse(key)] = Map<String, dynamic>.from(value);
        });
        
        // Notify listeners
        favoritesNotifier.value = Set.from(_favoriteIds);
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // Save favorites to storage
  Future<void> _saveFavorites() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Prepare data object
      final Map<String, dynamic> data = {
        'ids': _favoriteIds.toList(),
        'images': {},
      };
      
      // Add images
      _favoriteImages.forEach((key, value) {
        data['images'][key.toString()] = value;
      });
      
      // Save to storage
      await prefs.setString(_favoritesKey, json.encode(data));
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }
  
  // Clear all favorites
  Future<void> clearAllFavorites() async {
    _favoriteIds.clear();
    _favoriteImages.clear();
    await _saveFavorites();
    favoritesNotifier.value = Set.from(_favoriteIds);
  }
}