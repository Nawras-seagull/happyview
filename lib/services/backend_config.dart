/// The HappyView backend is the only host the app is allowed to call directly.
/// All third-party access (Pixabay, Telegram, etc.) must be routed through it.
// NOTE: this host does not currently terminate HTTPS (confirmed via direct test —
// connections to https://happyview.runasp.net fail outright). Revert to https://
// once TLS is actually enabled on the host; see /memories/repo/phase0-audit.md.
class BackendConfig {
  static const String baseUrl = 'http://happyview.runasp.net';
}
