import 'dart:io';
import 'package:flutter/foundation.dart';

/// The HappyView backend is the only host the app is allowed to call directly.
/// All third-party access (Pixabay, Telegram, etc.) must be routed through it.
class BackendConfig {
  static const bool isProd = bool.fromEnvironment('dart.vm.product');

  static final String baseUrl = isProd
      ? "https://happyview.runasp.net"
      : (kIsWeb
          ? "http://localhost:5161"
          : Platform.isAndroid
              ? "http://10.0.2.2:5161"
              : "http://localhost:5161");

  // Example service endpoints
  static String get imagesUrl => "$baseUrl/api/images";
  static String get authUrl => "$baseUrl/api/auth";
  static String get suggestionsUrl => "$baseUrl/api/suggestions";
}
