HappyView — Project Instructions
Read docs/ROADMAP.md before starting any work — it has the full target architecture and phase-by-phase rebuild plan. This file is just the always-on summary.
Current phase
Phase 0 — Audit (not yet started)
Non-negotiable rules
The Flutter app never calls a third party directly. Every external call (images via Pixabay, suggestions via Telegram) goes through the ASP.NET backend. The backend is the only gateway.
No analytics SDKs, no ad SDKs, no advertising identifiers (AAID/IDFA). This is a children's app under Google Play Families Policy and Apple's Kids Category guidelines (Guideline 1.3).
Firebase (firebase_core, firebase_auth, cloud_firestore) is being removed entirely — do not reintroduce it or add new Firebase products.
Secrets (Telegram bot token, any API keys) live server-side only — ASP.NET User Secrets locally, environment variables / a secrets manager in production. Never in the Flutter client, never committed to git.
Keep the parental gate in front of the suggestion form and any external links. Don't remove it or route around it.
Before adding any new package (Flutter or NuGet), check it against the compliance checklist in docs/ROADMAP.md Section 5 — some "harmless" packages (crash reporters, etc.) collect device identifiers by default.
Where things are
Backend: ASP.NET (.NET 9) Web API — /api/images (Pixabay proxy, done), /api/suggestions (Telegram relay, to build).
Frontend: Flutter, lib/main.dart is the entry point.
Localization: lib/l10n/app_en.arb, app_ar.arb, app_tr.arb — run flutter gen-l10n after editing any .arb file (requires flutter: generate: true in pubspec.yaml, already set).
Verify before trusting a prior agent's summary
Always re-check the actual repo state (grep for firebase, check pubspec.yaml, inspect the backend controllers) rather than assuming a previous session's progress notes are accurate.

