import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class SoundEffectHandler {
  static final SoundEffectHandler _instance = SoundEffectHandler._internal();
  factory SoundEffectHandler() => _instance;
  SoundEffectHandler._internal();

  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _yayPlayer = AudioPlayer();
  bool _initialized = false;
  bool _initializing = false;

  Future<void> initialize() async {
    if (_initialized || _initializing) return;
    _initializing = true;

    try {
      // Load assets directly (no longer using compute)
      await Future.wait([
        _clickPlayer.setAsset('assets/sounds/click.mp3'),
        _yayPlayer.setAsset('assets/sounds/yay.wav'),
      ]);
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing sound effects: $e');
      }
    } finally {
      _initializing = false;
    }
  }

  Future<void> playClick() async {
    if (!_initialized) {
      // Initialize without awaiting, but ensure we don't miss the first play
      unawaited(_initializeAndPlay(_clickPlayer));
      return;
    }

    try {
      await _clickPlayer.seek(Duration.zero);
      unawaited(_clickPlayer.play());
    } catch (e) {
      if (kDebugMode) {
        print('Error playing click sound: $e');
      }
    }
  }

  Future<void> playYay() async {
    if (!_initialized) {
      unawaited(_initializeAndPlay(_yayPlayer));
      return;
    }

    try {
      await _yayPlayer.seek(Duration.zero);
      unawaited(_yayPlayer.play());
    } catch (e) {
      if (kDebugMode) {
        print('Error playing yay sound: $e');
      }
    }
  }

  Future<void> _initializeAndPlay(AudioPlayer player) async {
    await initialize();
    try {
      await player.seek(Duration.zero);
      unawaited(player.play());
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound after initialization: $e');
      }
    }
  }

  void dispose() {
    _clickPlayer.dispose();
    _yayPlayer.dispose();
    _initialized = false;
  }
}

void unawaited(Future<void> future) {}