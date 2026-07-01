# Honeymoon — Session Handoff

Status doc for picking up work in a new session. Last updated 2026-07-01.

## What this app is
A SwiftUI + Firebase iOS app for **couples' romantic travel**. Started as a
"Tinder-for-honeymoons" swipe deck; now a monetized planner for **all couples'
trips** — honeymoons, anniversaries, romantic getaways, babymoons — with AI
itineraries, shared real-time trip planning, couple matching, StoreKit Premium,
affiliate booking links, live weather, and a searchable catalogue. The App Store
name stays **"Honeymoon"** (broadened positioning, same name/bundle id
`com.thetpine.honeymoon`).

## Git state
- **Everything is on `main`** (origin: `github.com/Thet9354/Honeymoon`), pushed.
- `main` HEAD includes: P1–P6, **Stage A** (Claude AI itineraries via Cloud
  Function), **Stage B** (shared trip planning), **Stage C** (match paywall +
  affiliate), **B1** (anonymous/guest auth), **B2** (itinerary→planner bridge),
  **B3** (one free AI preview), **N1** (local countdown notifications), **N2**
  (readiness checklist), **N3** (destination map), **N4** (design tokens), plus the
  recent block below.
- **Recent work (this handoff):**
  - Catalogue grown **21 → 41** destinations; **paged photo galleries** with
    tap-to-zoom on the detail screen; extra photos stream from Wikimedia Commons
    via a cached/retrying loader (`RemoteImageLoader`).
  - **Reliability:** maps use **stored coordinates** (no geocoder throttling);
    remote images self-heal transient failures; deck **loading/empty** states.
  - **Deck-card sizing fix:** all cards render at the original **0.625 portrait**
    ratio (`scaledToFill` + clip) regardless of source photo dimensions.
  - **Design tokens:** all `.pink` → `Color.brand` (a `ShapeStyle where Self ==
    Color` extension); `PrimaryButtonStyle` adopted. Rebrand from `Theme.swift`.
  - **Couples-travel pivot:** `TripOccasion` (honeymoon / anniversary / getaway /
    babymoon) chosen in onboarding; tailors AI plan length/tone/copy; paywall
    leads with the **Annual** subscription (Lifetime kept); getaways rank
    shorter-haul destinations.
  - **Travel-insurance affiliate** on the readiness checklist ("Get a quote").
  - **Live weather** (Open-Meteo, keyless) on the detail screen.
  - **Explore** screen — searchable/filterable catalogue browser (header 🔍).
  - **Security hardening** — see `SECURITY.md` (invite/couple rules, account
    deletion). One real hole remains (S1, see below).
  - **Unit tests** — `HoneymoonTests` target, 13 passing pure-logic tests.
- Repo conventions: this folder is iCloud-synced and spawns `" 2"`-suffixed junk
  files — **always `git add <explicit paths>`, never `git add -A`**. New Swift files
  are added to `Honeymoon.xcodeproj/project.pbxproj` **by hand** with fabricated
  24-hex IDs (prefixes: `AAFF/AABB/AACC/AADD` for P1–P6, `AAEE####` for AI/v2 work
  — continue that scheme; latest used: `AAEE4444` WeatherService, `AAEE5555`
  BrowseView, `AAEE6666` test target). No synchronized groups.
- `Honeymoon/Honeymoon.entitlements` and `xcuserdata/.../xcschememanagement.plist`
  may show as locally modified — expected, leave them.

## Build, run & test
```bash
# Build
xcodebuild -project Honeymoon.xcodeproj -scheme Honeymoon \
  -destination 'generic/platform=iOS Simulator' -configuration Debug \
  build CODE_SIGNING_ALLOWED=NO

# Test (13 pure-logic unit tests; or ⌘U in Xcode)
xcodebuild test -project Honeymoon.xcodeproj -scheme Honeymoon \
  -destination 'platform=iOS Simulator,name=iPhone 15' CODE_SIGNING_ALLOWED=NO
```
Firebase project: `honeymoon-fbd08`. The app forces NO auth wall — after onboarding
it lands on the deck via an anonymous "guest" session.

## Architecture notes
- **AI itineraries**: the Anthropic key must not ship in-app, so generation goes
  through a Firebase **Cloud Function** (`functions/index.js`, Node +
  `@anthropic-ai/sdk`, Claude `claude-opus-4-8` behind a one-line `MODEL` const).
  `ItineraryService` is cache-first (`users/{uid}/itineraries/{destId}`) → function
  → deterministic `Itinerary.generate(...)` fallback. Now **occasion-aware**: the
  client sends the `TripOccasion` + occasion-driven day count; the fallback adapts
  length even before the function is redeployed. Function is auth-gated +
  premium-gated + monthly-capped, with a 1-per-account free preview.
- **Shared planning**: `TripPlanStore` uses `couples/{coupleId}/trips/{destId}` when
  linked (else per-user), real-time listeners, per-item budget/checklist
  subcollections. Rules in `firestore.rules`.
- **Auth**: anonymous on launch; `AuthViewModel` links to email/Google/Apple on
  sign-up so guest data carries over.
- **Weather**: `WeatherService` (Open-Meteo, no key) using stored coordinates.
- **Notifications**: `NotificationService` schedules **local** countdown nudges.

## ⚠️ External steps (console/App-Store — not codeable here)
1. **Re-publish `firestore.rules`** in the Firebase console — required for the new
   invite/couple security hardening (S2) to take effect.
2. **Firebase Blaze + deploy functions** + `firebase functions:secrets:set
   ANTHROPIC_API_KEY` — turns on real AI itineraries. **Re-deploy** so the new
   occasion-aware prompt in `functions/index.js` goes live (fallback works meanwhile).
3. **S1 — server-authoritative premium** + **Firebase App Check** — the one real
   security hole (premium flag is client-spoofable) plus abuse hardening. Exact
   recipe in **`SECURITY.md`**. Needs App Store Connect / Firebase console.
4. **Enable Anonymous sign-in** in the Firebase console (guest persistence).
5. **Affiliate IDs** in `Honeymoon/Repository/AffiliateLinks.swift` (Booking.com /
   GetYourGuide / travel-insurance partner).
6. **App Store**: paid Apple Developer Program (Sign in with Apple + submission),
   screenshots, metadata, privacy labels, archive. (App Icon, launch screen, and
   in-app account deletion already done.)

## Backlog (recommended next)
- **Complete S1 + App Check** (security) — see `SECURITY.md`. Highest priority once
  you have console access.
- **Remote push notifications** — APNs + FCM via Cloud Function (needs Blaze + paid
  program). Local nudges (N1) already exist.
- **Expand the test suite** — the `HoneymoonTests` target exists; add coverage
  (e.g. `TripPlan` budget totals/checklist progress, `AffiliateLinks` URL building).
- **Analytics** (privacy-respecting) to measure the occasion pivot + conversion.
- **Accessibility & localization** pass.
- Nice-to-haves: date-aware weather for the trip's start date; map/photo polish.
- ✅ Recently done: bigger catalogue + galleries; empty/loading polish; design
  tokens; travel-insurance affiliate; live weather; Explore search/filter;
  couples-travel pivot; security S2/S4; unit-test baseline.

## Key files
- Occasions / preferences: `Honeymoon/Model/TravelPreferences.swift` (`TripOccasion`,
  `Interest`, `BudgetBand`, ranking), `Honeymoon/ViewModel/PreferenceStore.swift`,
  `Honeymoon/View/Onboarding/PreferenceQuizView.swift`
- Cloud Function: `functions/index.js`
- AI client: `Honeymoon/ViewModel/ItineraryService.swift`, `Honeymoon/Model/Itinerary.swift`, `Honeymoon/View/Detail/ItineraryView.swift`
- Detail screen (gallery, map, weather, teaser): `Honeymoon/View/Detail/DestinationDetailView.swift`
- Weather: `Honeymoon/ViewModel/WeatherService.swift`
- Explore/browse: `Honeymoon/View/Browse/BrowseView.swift`
- Deck: `Honeymoon/View/ContentView.swift`, `Honeymoon/View/CardView.swift`, `Honeymoon/View/HeaderView.swift`
- Paywall/IAP: `Honeymoon/View/Paywall/PaywallView.swift`, `Honeymoon/ViewModel/PurchaseStore.swift`
- Shared planning: `Honeymoon/ViewModel/TripPlanStore.swift`, `Honeymoon/View/Trip/TripPlannerView.swift`, `firestore.rules`
- Couple/match: `Honeymoon/ViewModel/CoupleStore.swift`, `Honeymoon/View/Couple/*`
- Auth: `Honeymoon/ViewModel/AuthViewModel.swift`, `Honeymoon/View/RootView.swift`
- Catalogue data: `Honeymoon/Data/HoneymoonData.swift`, `Honeymoon/Model/HoneymoonModel.swift`
- Design tokens: `Honeymoon/Modifier/Theme.swift`
- Security review + runbook: `SECURITY.md`
- Tests: `HoneymoonTests/HoneymoonLogicTests.swift`
