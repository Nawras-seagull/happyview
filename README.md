# Happy View

A Flutter app for kids to browse safe, curated pictures — animals, nature, space, shapes, vehicles, and more — with zero ads, zero analytics, and zero data collection beyond what's strictly needed. Published on Google Play as `com.nawras.happyview`, with iOS in progress.

Built to meet Google Play Families Policy and Apple's Kids Category guidelines end-to-end. See [`docs/ROADMAP.md`](docs/ROADMAP.md) for the full architecture brief and phased plan — it's written to be handed to any engineer (or AI agent) picking up the project cold.

## Motivation

I built this as a mother with curious kids who wanted to explore photos — animals, space, nature, whatever caught their interest. I couldn't fully trust how the big platforms handle that for children, and most "kids" apps are saturated with ads. Happy View is the app I wanted to hand my own kids: no ads, no tracking, no ambiguity about where their data goes.

## Why this project is interesting

Most portfolio apps show off UI. This one shows a real constraint: **building for a regulated audience.** Google Play Families Policy and Apple's Kids Category impose hard rules — no advertising identifiers, no third-party analytics, no unmanaged third-party network calls — and the interesting engineering problem is architecting around that, not just building a chat app or a CRUD list.

The concrete decision this project is built around: **the Flutter client never talks to a third party directly.** Every external call — fetching images, translating a search query, relaying a suggestion — goes through an ASP.NET backend that Nawras owns. That single rule is what makes the privacy story simple to state and simple to verify: "the app talks only to our backend."

## Architecture

```
┌──────────────┐        HTTPS only        ┌───────────────────────┐
│  Flutter App  │ ────────────────────────▶│   ASP.NET Backend API  │
│ (no 3rd-party │                          │   (single gateway)      │
│  SDKs beyond   │◀──────────────────────── │                         │
│  http/dio;     │                          │  /api/images   → Pixabay │
│  no ads,        │                          │  /api/search    → Pixabay │
│  no analytics)  │                          │  /api/translate → Google Translate │
│                │                          │  /api/suggestions → Telegram Bot API │
└──────────────┘                          └───────────────────────┘
```

- **Frontend** — Flutter, `lib/main.dart` entry point. Category browsing, live search with in-app profanity filtering, favorites, a "surprise me" random picture button, and a math-challenge parental gate in front of settings (which is the only path to the suggestion/feedback form).
- **Backend** — ASP.NET Core (.NET, minimal API) in `HappyviewProxy/`. Proxies Pixabay image search, relays a search-query translation, and forwards parent-gated suggestion-form submissions to a private Telegram chat. Rate-limited (3 requests/minute/IP on the suggestion endpoint) to prevent abuse via a decompiled client. Nothing is persisted — the suggestion relay is stateless by design.
- **Localization** — English, Arabic, and Turkish (`lib/l10n/`), including a fully localized in-app privacy policy.

## Compliance-driven decisions

- **No Firebase.** The app previously used `firebase_auth` and Firestore to store suggestion-form submissions. Both are gone — replaced with a stateless Telegram relay through the owned backend, removing an entire category of third-party data handling.
- **No analytics or ad SDKs, no advertising identifiers (AAID/IDFA).** Verified by dependency audit, not just by omission — `pubspec.yaml` has no analytics/ads packages.
- **Secrets never ship in the client.** The Telegram bot token lives server-side only (ASP.NET User Secrets locally, environment config in production) — never in the Flutter app, never committed to source control.
- **Parental gate in front of anything data-adjacent.** A math-challenge dialog gates the entire settings menu, which is the only route to the suggestion form.

Full checklist and phased rollout plan: [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Stack

Flutter · Provider (state management) · ASP.NET Core (.NET) minimal API · Pixabay API (proxied) · Telegram Bot API · flutter_localizations (en/ar/tr)

## Status

Live on Google Play. Backend and Flutter client both route exclusively through the owned API gateway; HTTPS is enforced end-to-end. iOS release and the remaining store-metadata updates (Play Data Safety form, Apple Privacy Nutrition Label) are in progress per the roadmap's later phases.