HappyView Rebuild — Architecture & Multi-Agent Roadmap
Purpose of this document: This is a self-contained brief for any AI coding agent (Claude, GPT, Gemini, etc.) picking up work on this project. Paste it in full at the start of a new agent session so it has full context without needing to re-derive decisions already made.


1. Project Context
App: HappyView (com.nawras.happyview) — a Flutter app for kids to view pictures, published on Google Play. iOS release also targeted.
Audience: Children. Must comply with Google Play Families Policy and Apple App Store Kids Category guidelines (Guideline 1.3), plus general COPPA-adjacent data-minimization principles.
Current stack (pre-rebuild):
Flutter frontend
Firebase: firebase_core, firebase_auth, cloud_firestore (Firestore used only to store parent-gated suggestion-form submissions)
Images previously came from Pixabay API called directly from the app; already migrated to a .NET backend proxy so the app no longer talks to Pixabay directly
A parent-gated feedback/suggestion form exists in-app already
Decision made: Abandon Firebase entirely. Replace Firestore-based suggestion storage with a Telegram bot notification, routed through the existing/expanded ASP.NET backend (not called directly from the client).
Target stack (post-rebuild):
Frontend: Flutter (client only — no direct third-party network calls except to the owned backend)
Backend: ASP.NET (.NET 9) Web API — the single gateway to all third-party services (Pixabay, Telegram)
No Firebase, no analytics SDK, no ad SDK, no advertising identifiers


2. Target Architecture
┌─────────────────┐        HTTPS only        ┌──────────────────────┐

│   Flutter App    │ ───────────────────────▶ │  ASP.NET Backend API  │

│ (no 3rd-party     │                          │  (single gateway)      │

│  SDKs beyond       │ ◀─────────────────────── │                        │

│  http/dio, no       │                          │  /api/images  ──▶ Pixabay │

│  ads, no analytics)│                          │  /api/suggestions ─▶ Telegram Bot API │

└─────────────────┘                          └──────────────────────┘
Guiding principles
The Flutter app never talks to a third party directly. Every external call (images, suggestions, anything future) goes through the backend. This makes the privacy policy simple: "the app talks only to our backend."
Data minimization. Don't persist anything you don't need. The suggestion relay should be stateless where possible — receive, forward to Telegram, discard. If you need an audit trail, store only what's necessary and define a retention/deletion policy.
No identifiers. No AAID/IDFA, no device fingerprinting, no analytics SDK of any kind (first-party or third-party).
Parental gate stays in front of anything data-adjacent. Suggestion form, any external links, any settings that could expose the child to non-child content.
Secrets never ship in the client. Telegram bot token, any API keys — all live server-side only (ASP.NET User Secrets locally, environment variables / a secrets manager in production). Never hardcode in Flutter or commit to the repo.


3. Backend (ASP.NET) — Endpoints to Build
POST /api/images
Already exists (Pixabay proxy). Carry forward as-is; verify it doesn't log or forward any client-identifying data (IP is unavoidable at the HTTP level, but don't add device IDs, user IDs, etc. to the request).
POST /api/suggestions
Input: { content: string (1–200 chars), email?: string, category?: string }
Behavior:
Validate input server-side (length limits, basic sanitization — this is user-generated text reaching a human via Telegram).
Forward as a formatted message to your Telegram bot via https://api.telegram.org/bot<TOKEN>/sendMessage, targeting your own chat ID.
Return a simple success/failure response to the app. No suggestion content needs to be echoed back.
Rate-limit this endpoint (e.g. ASP.NET's built-in rate limiting middleware) to prevent abuse of your Telegram bot via a decompiled client.
Do not persist to a database unless you have a specific reason to (e.g. duplicate-submission detection). If you do persist, document retention period and add a deletion job.
Secrets: Telegram bot token stored via dotnet user-secrets locally, and an environment variable / secret store in production. Never in appsettings.json committed to source control.
General backend hardening
HTTPS only (redirect HTTP → HTTPS, HSTS in production).
CORS: restrict to what's needed (mobile apps don't send an Origin header the way browsers do, but lock this down if you ever add a web client).
Structured logging that excludes suggestion content/email from logs where possible, or redacts it — logs are a place PII can leak unintentionally.
Health check endpoint for monitoring.


4. Frontend (Flutter) — Changes to Make
Remove Firebase entirely from pubspec.yaml:
firebase_core
firebase_auth (confirm nothing else depends on it before removing — check for any auth-gated feature first)
cloud_firestore
Run flutter pub get after removal; remove any now-unused Firebase.initializeApp() calls, firebase_options.dart, and google-services.json / GoogleService-Info.plist if nothing else in the app needs Firebase.
Replace SuggestionService (currently writes to Firestore) with an HTTP client call (dio or http, both already dependencies) to POST {backend_base_url}/api/suggestions.
Keep the parental gate wrapping the suggestion form exactly as-is — this already satisfies verifiable-parental-consent requirements for collecting an optional email.
Audit for any other direct third-party calls in the codebase (grep for http.get, http.post, Dio(, hardcoded external URLs) to confirm everything routes through the backend.
Confirm no analytics/ad SDKs remain — search pubspec.yaml for any package with "analytics", "ads", "admob", "facebook", "mixpanel", etc.


5. Compliance Checklist (Google Play Families Policy + Apple Kids Category)
No advertising identifiers (AAID/IDFA) collected — satisfied by not including any Analytics/Ads SDK at all.
No behavioral or third-party advertising in the app.
No third-party analytics SDKs.
All data collection (currently: optional email via suggestion form) disclosed accurately in the privacy policy, in each supported language.
Suggestion form gated behind a parental gate (already true — keep it).
No external links reachable without a parental gate (audit any "rate us," "share," "visit our website" buttons).
Google Play Data Safety form updated to match the new architecture (no Firebase Analytics, no ad ID collection; disclose the suggestion-relay data flow).
Apple Privacy Nutrition Label updated similarly in App Store Connect.
Privacy policy rewritten to describe: (a) no user registration, (b) the app backend as the only network destination, (c) optional email via parent-gated form relayed to a private channel, (d) no ads/analytics/ad identifiers/precise location collected.
Backend endpoint that handles the suggestion relay is rate-limited and doesn't leak the Telegram bot token to the client.


6. Phased Roadmap
Phase 0 — Audit (do this first, in any new agent session)
Confirm current Firebase usage: grep the codebase for firebase_auth usage to see if it's actually wired to any feature, or just an unused dependency.
Confirm which files still reference Firestore (SuggestionService, cloud_firestore imports).
List every outbound HTTP call in the Flutter app to confirm the backend is the only destination.
Phase 1 — Backend build-out
Extend the existing ASP.NET project with /api/suggestions.
Add rate limiting middleware.
Store the Telegram bot token via secrets, not config files in source control.
Test the endpoint independently (e.g. via curl or Postman) before wiring the Flutter side.
Phase 2 — Flutter migration
Remove Firebase packages and initialization code.
Point SuggestionService at the new backend endpoint.
Regression-test the parental gate → suggestion form → submission flow end-to-end against the real backend.
Phase 3 — Cleanup & dependency audit
Remove firebase_options.dart, google-services.json, GoogleService-Info.plist if nothing else needs them.
Remove the earlier google_analytics_* manifest meta-data and GOOGLE_ANALYTICS_* Info.plist keys added during the (now-moot) AAID mitigation — they're inert without the Analytics SDK, but removing them keeps the project honest about what it actually does.
Run flutter analyze and fix any dangling imports/warnings from the removal.
Phase 4 — Privacy policy & store metadata rewrite
Rewrite privacyPolicyContent in all three .arb files (app_en.arb, app_ar.arb, app_tr.arb) to reflect the final architecture accurately.
Run flutter gen-l10n and confirm the generated Dart files contain the new text.
Update Google Play Data Safety form and Apple Privacy Nutrition Label to match.
Phase 5 — QA
Test on a real device: suggestion submission, parental gate, image loading via backend proxy.
Confirm no network calls leave the device except to your backend domain (use a proxy tool like Proxyman/Charles to verify).
Load-test or at least sanity-test the rate limiter on /api/suggestions.
Phase 6 — Release
Bump version in pubspec.yaml (versionCode/versionName).
flutter build appbundle (Android) and archive via Xcode (iOS).
Submit to Play Console and App Store Connect with updated Data Safety / Privacy Nutrition Label answers.
Monitor review feedback — Kids Category / Families Policy reviews sometimes come back with follow-up questions; having this document handy makes it easy to answer precisely what data flows where.


7. Notes for Agent Handoffs
If you're an agent picking this up mid-stream, start with Phase 0 even if a previous agent claims later phases are done — verify against the actual current state of the repo rather than trusting summarized progress.
Don't reintroduce any third-party SDK (analytics, ads, crash reporting) without checking it against the compliance checklist in Section 5 first — many "harmless" SDKs (including some crash reporters) collect device identifiers by default.
Keep this document updated as decisions change — future agents should treat divergence between this doc and the actual code as a sign to reconcile, not to silently follow whichever they saw first.

