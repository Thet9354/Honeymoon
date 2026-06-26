# Honeymoon — maintenance scripts

## Seed the Firestore `destinations` collection

Uploads the 21 bundled destinations (mirror of `Honeymoon/Data/HoneymoonData.swift`)
into Firestore using the Firebase Admin SDK. The Admin SDK bypasses security
rules, so the client-facing read-only rule on `destinations` stays untouched.

### One-time setup

1. **Get a service-account key** (Firebase console):
   - Open the Firebase console → project **honeymoon-fbd08**.
   - Gear icon → **Project settings** → **Service accounts** tab.
   - Click **Generate new private key** → confirm → a `.json` file downloads.
   - Move/rename it to: `scripts/serviceAccountKey.json`
   - ⚠️ This key grants full admin access. It is git-ignored — never commit or share it.

2. **Install dependencies** (from this `scripts/` folder):
   ```sh
   npm install
   ```

### Run it

```sh
npm run seed
```

Expected output: `✅ Seeded 21 destinations to Firestore.`

Re-running is safe — documents are keyed by `id` and written with `{ merge: true }`,
so this doubles as the "update content" step whenever you edit the catalog later.

### After seeding

The app already reads from Firestore first (falling back to the bundled catalog
when the collection is empty), so once seeded it will serve the Firestore copy
automatically — no app change or rebuild needed.
