# Security notes & runbook

Findings from the app security review, what's been fixed in code, and the steps
that require your Firebase / App Store Connect console access.

## ✅ Fixed in code (branch `catalog-galleries`)

### S2 — Invite / couple hardening
- `firestore.rules`: invites are now **`get`-only** (no `list`), so a signed-in
  user can resolve a code they were given but **cannot enumerate** every
  code→coupleId. Creating an invite requires you to belong to the target couple;
  deleting one is restricted to the creator or a couple member.
- `CoupleStore`: invites now record `createdBy`, are **single-use** (deleted on
  redemption and on leaving the couple), and codes are **8 chars** (from a
  31-symbol unambiguous alphabet ≈ 8.5×10¹¹ combinations) instead of 6.
- **Action:** re-publish `firestore.rules` in the Firebase console (Firestore →
  Rules → paste → Publish). Existing 6-char invites keep working; new ones are 8.

### S4 — Account-deletion cleanup
- `AuthViewModel.deleteAccount` now removes the user from their couple and retires
  the couple's pending invite before deleting the account, so a partner isn't left
  linked to a ghost and stale codes can't be redeemed.

## ⚠️ Needs your console access

### S1 — Premium entitlement is client-spoofable (highest priority)
**Problem.** The app mirrors its StoreKit entitlement into
`users/{uid}.isPremium` (`PurchaseStore.mirrorEntitlement`), and the itinerary
Cloud Function trusts that flag. Because Firestore rules let a user write their
own `users/{uid}` doc, a determined user can set `isPremium: true` themselves and
unlock premium AI generation (bounded only by the per-user `MONTHLY_CAP = 30`, so
~$3–4.5/mo worst case). It defeats the paywall.

**Proper fix (server-authoritative entitlement).** Do these together:

1. **App Store Server Notifications V2** → a new Cloud Function. In App Store
   Connect set the production + sandbox notification URL to a new function, e.g.
   `https://<region>-honeymoon-fbd08.cloudfunctions.net/appStoreNotifications`.
   That function verifies Apple's signed payload and sets `users/{uid}.isPremium`
   via the **Admin SDK** (which bypasses rules). To map a transaction → uid, set
   an `appAccountToken` (a per-user UUID stored on the user doc) as a purchase
   option on the client and read it back from the notification.
2. **Lock the field in `firestore.rules`** so the client can't set it — replace
   the `users/{uid}` write rule with one that rejects any change to `isPremium`:
   ```
   match /users/{uid} {
     allow read: if request.auth != null && request.auth.uid == uid;
     allow write: if request.auth != null && request.auth.uid == uid
                  && (!request.resource.data.diff(resource.data).affectedKeys().hasAny(['isPremium']));
     // isPremium is written only by the Admin SDK (server), which bypasses rules.
   }
   ```
3. **Remove `mirrorEntitlement`'s client write** once (1) is live (until then,
   keep it — flipping the rule first would lock out real buyers).

**Interim mitigation:** enable App Check (below) — it blocks non-app clients from
calling Firestore/Functions, which removes the easy "forge a REST write with my
token" path for casual abuse.

### S3 / abuse — Firebase App Check
Anonymous auth + a per-account free-preview allowance means throwaway accounts can
farm free itineraries; and nothing today proves a Firestore/Functions caller is
*our app*. **Enable Firebase App Check** (App Attest on iOS):
- Firebase console → App Check → register the iOS app with the **App Attest**
  provider; start in **monitor** mode, then **enforce** for Firestore + Cloud
  Functions once healthy.
- Add the `FirebaseAppCheck` SPM product to the app target and install a provider
  factory at launch (App Attest for release, `AppCheckDebugProvider` for DEBUG/
  simulator). This is a small code change but must land with the console
  registration or it will fail closed — do them together.

## Verified OK
Anthropic key is server-only (never shipped in the app); the itinerary function is
auth-gated with an atomic monthly cap; couple/trip data is scoped to members;
no `http://` / arbitrary-loads ATS holes; email verification is sent on sign-up;
`GoogleService-Info.plist` embedding is normal (that key is not a secret).
