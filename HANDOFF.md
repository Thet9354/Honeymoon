# Honeymoon — Session Handoff

Status doc for picking up work in a new session. Last updated 2026-06-28.

## What this app is
A SwiftUI + Firebase iOS app: a "Tinder-for-honeymoons" swipe deck that grew into a
monetized couples' honeymoon-planning app (AI itineraries, shared trip planning,
couple matching, StoreKit Premium, affiliate booking links).

## Git state
- Everything is merged to **`main`** (origin: `github.com/Thet9354/Honeymoon`).
- **Unmerged branch `catalog-galleries`** (off `main`) holds recent work: backlog
  #2/#4/#5/#6 + two reliability fixes, a **deck-card sizing fix** (uniform 0.625
  portrait cards), and the **couples-travel pivot** — the app now serves all
  couples' trips, not just honeymoons. A `TripOccasion` (honeymoon / anniversary /
  romantic getaway / babymoon) is chosen in onboarding and tailors the AI plan's
  length, tone and copy; the paywall leads with the Annual subscription (Lifetime
  kept); getaways rank shorter-haul destinations. App name stays "Honeymoon".
- `main` HEAD includes: P1–P6, **Stage A** (Claude AI itineraries via Cloud Function),
  **Stage B** (shared real-time trip planning), **Stage C** (match-moment paywall +
  affiliate + pricing), **B1** (browse-before-sign-in / anonymous auth), **B3** (one
  free AI itinerary preview), **B2** (itinerary→planner bridge), **N1** (local
  countdown notifications), **N2** (readiness checklist), **N3** (destination map),
  **N4** (design tokens).
- Repo conventions: this folder is iCloud-synced and spawns `" 2"`-suffixed junk
  files — **always `git add <explicit paths>`, never `git add -A`**. New Swift files
  are added to `Honeymoon.xcodeproj/project.pbxproj` **by hand** with fabricated 24-hex
  IDs (existing prefixes: `AAFF/AABB/AACC/AADD` for P1–P6, `AAEE####` for the AI/v2
  work — continue that scheme). There are no synchronized groups.
- `Honeymoon/Honeymoon.entitlements` may show as locally modified (Apple Sign-In
  capability toggled for free-team device builds) — that's expected, leave it.

## Build & run
```bash
xcodebuild -project Honeymoon.xcodeproj -scheme Honeymoon \
  -destination 'generic/platform=iOS Simulator' -configuration Debug \
  build CODE_SIGNING_ALLOWED=NO
```
Firebase project: `honeymoon-fbd08`. The app currently forces NO auth wall — after
onboarding it lands on the deck via an anonymous "guest" session.

## Architecture notes
- **AI itineraries**: Swift has no Anthropic SDK and the key must not ship in-app, so
  generation goes through a Firebase **Cloud Function** (`functions/`, Node +
  `@anthropic-ai/sdk`, Claude `claude-opus-4-8`, model behind a one-line constant).
  `ItineraryService` is cache-first (`users/{uid}/itineraries/{destId}`) → function →
  deterministic `Itinerary.generate(...)` fallback (so the app works even before the
  function is deployed). Function is auth-gated + premium-gated (`users/{uid}.isPremium`,
  mirrored from StoreKit in `PurchaseStore`) with a per-user monthly cap, plus a 1-per-
  account FREE preview allowance for non-premium users.
- **Shared planning**: `TripPlanStore` uses `couples/{coupleId}/trips/{destId}` when
  linked (else per-user), real-time snapshot listeners, budget/checklist as per-item
  subcollections (avoids clobbering). Rules in `firestore.rules`.
- **Auth**: anonymous on launch; `AuthViewModel` links the anon account to email/Google/
  Apple on sign-up so guest data carries over.
- **Notifications**: `NotificationService` schedules **local** countdown nudges (no APNs).

## ⚠️ External steps the user must do (not codeable here)
1. **Firebase Blaze plan** + `firebase deploy --only functions` + `firebase functions:secrets:set ANTHROPIC_API_KEY` — turns on real AI itineraries (until then the deterministic fallback is used; no app update needed when it goes live). **Re-deploy needed** for the couples-travel change: `functions/index.js` now generalises the prompt and accepts an `occasion`. The occasion-aware deterministic fallback already works pre-deploy.
2. **Enable Anonymous sign-in** in Firebase console (Authentication → Sign-in method) — required for guest persistence (app still runs without it).
3. **Publish `firestore.rules`** in the console — required for shared trip planning.
4. **Affiliate IDs** in `Honeymoon/Repository/AffiliateLinks.swift` after Booking.com / GetYourGuide sign-up.
5. **App Store**: paid Apple Developer Program (needed for Sign in with Apple + submission), screenshots, metadata/keywords, privacy nutrition labels, archive. (App Icon + launch screen + in-app account deletion are already done.)

## Backlog (recommended next, in priority order)
1. **Remote push notifications** — APNs + FCM via Cloud Function (needs Blaze + paid program). Local countdown nudges already exist (N1).
2. ✅ **DONE** (branch `catalog-galleries`) — **Bigger destination catalog + photo gallery**: catalog grown **21 → 41** destinations, each with a bundled primary photo + real coordinates; paged photo gallery with page-dots and tap-to-zoom in `DestinationDetailView`; extra gallery photos stream from Wikimedia Commons via a disk+memory-cached, retrying loader (`RemoteImageLoader`). Also fixed two reliability issues found in testing: maps now use **stored coordinates** (no geocoder throttling) and gallery images self-heal transient failures. New `Destination` fields: `gallery: [String]`, `latitude`/`longitude`. New bundled assets live under `Assets.xcassets/Photos/` (no pbxproj edits needed — `.xcassets` is a folder resource).
3. **Live weather** on the detail screen — needs a weather API key. (Only remaining codeable item, gated on a key.)
4. ✅ **DONE** (branch `catalog-galleries`) — **Empty/loading-state polish**: the swipe deck now shows a branded loading card while destinations load and a retryable empty state on failure (`ContentView`). Saved/planner already had adequate states.
5. ✅ **DONE** (branch `catalog-galleries`) — **Design-token rollout**: every hardcoded `.pink` replaced with the `Color.brand` token (now a `ShapeStyle where Self == Color` extension, so `.brand` is a drop-in for `.pink` everywhere); `PrimaryButtonStyle` adopted for the remaining hand-rolled brand CTAs. Rebrand the whole app from `Theme.swift`.
6. ✅ **DONE** (branch `catalog-galleries`) — **Travel-insurance affiliate**: the readiness checklist's "Travel insurance" item shows a "Get a quote" link (2 travellers, deep-linked to trip dates). Set `insurancePartnerID` in `AffiliateLinks.swift` after partner sign-up.

Branch `catalog-galleries` (off `main`) holds items #2, #4, #5, #6 plus the two reliability fixes — not yet merged/pushed.

## Key files
- Cloud Function: `functions/index.js`
- AI client: `Honeymoon/ViewModel/ItineraryService.swift`, `Honeymoon/Model/Itinerary.swift`, `Honeymoon/View/Detail/ItineraryView.swift`
- Paywall/IAP: `Honeymoon/View/Paywall/PaywallView.swift`, `Honeymoon/ViewModel/PurchaseStore.swift`
- Shared planning: `Honeymoon/ViewModel/TripPlanStore.swift`, `Honeymoon/View/Trip/TripPlannerView.swift`, `firestore.rules`
- Couple/match: `Honeymoon/ViewModel/CoupleStore.swift`, `Honeymoon/View/Couple/*`
- Auth: `Honeymoon/ViewModel/AuthViewModel.swift`, `Honeymoon/View/RootView.swift`
- Deck: `Honeymoon/View/ContentView.swift`, `Honeymoon/View/CardView.swift`
- Notifications: `Honeymoon/ViewModel/NotificationService.swift`
- Design tokens: `Honeymoon/Modifier/Theme.swift`
