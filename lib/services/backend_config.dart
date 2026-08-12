/// The HappyView backend is the only host the app is allowed to call directly.
/// All third-party access (Pixabay, Telegram, etc.) must be routed through it.
class BackendConfig {
  static const String baseUrl = 'https://happyview.runasp.net';
}
