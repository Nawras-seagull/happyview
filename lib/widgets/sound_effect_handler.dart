import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

// A singleton class to manage sound effects efficiently
class SoundEffectHandler {
  // Singleton instance
  static final SoundEffectHandler _instance = SoundEffectHandler._internal();
  factory SoundEffectHandler() => _instance;
  SoundEffectHandler._internal();

  // Players for different sound effects
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _yayPlayer = AudioPlayer();
  
  // Track initialization state
  bool _initialized = false;
  
  // Preload all sound effects
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Load sounds in parallel
      await Future.wait([
        _clickPlayer.setAsset('assets/sounds/click.mp3'),
        _yayPlayer.setAsset('assets/sounds/yay.wav'),
      ]);
      
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing sound effects: $e');
      }
    }
  }
  
  // Play click sound
  Future<void> playClick() async {
    if (!_initialized) await initialize();
    
    try {
      await _clickPlayer.seek(Duration.zero);
      await _clickPlayer.play();
    } catch (e) {
      if (kDebugMode) {
        print('Error playing click sound: $e');
      }
    }
  }
  
  // Play yay sound
  Future<void> playYay() async {
    if (!_initialized) await initialize();
    
    try {
      await _yayPlayer.seek(Duration.zero);
      await _yayPlayer.play();
    } catch (e) {
      print('Error playing yay sound: $e');
    }
  }
  
  // Dispose resources
  void dispose() {
    _clickPlayer.dispose();
    _yayPlayer.dispose();
    _initialized = false;
  }
}