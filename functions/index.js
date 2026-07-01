//
//  index.js
//  Honeymoon Cloud Functions
//
//  Secure server-side proxy that generates a personalized honeymoon itinerary
//  with Claude. The Anthropic API key never ships in the app — it is stored as a
//  Functions secret and only ever used here. The call is gated so it costs money
//  only for paying users, and a hard per-user monthly cap bounds worst-case spend.
//

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const Anthropic = require("@anthropic-ai/sdk");

admin.initializeApp();

const ANTHROPIC_API_KEY = defineSecret("ANTHROPIC_API_KEY");

// Cost lever: switch to "claude-sonnet-4-6" here for ~half the per-call cost.
const MODEL = "claude-opus-4-8";
// Hard backstop: max generations per user per calendar month. Each itinerary
// costs ~$0.10–0.15, so this bounds the absolute worst case to a few dollars
// even if the premium gate were somehow bypassed.
const MONTHLY_CAP = 30;
// Free preview allowance for non-premium users (lifetime per account) — lets a
// couple experience one real AI itinerary before the paywall.
const FREE_LIMIT = 1;

// JSON shape Claude must return — mirrors the Swift `Itinerary` model.
const ITINERARY_SCHEMA = {
  type: "object",
  properties: {
    days: {
      type: "array",
      items: {
        type: "object",
        properties: {
          title: { type: "string" },
          morning: { type: "string" },
          afternoon: { type: "string" },
          evening: { type: "string" },
          dining: { type: "string" },
        },
        required: ["title", "morning", "afternoon", "evening", "dining"],
        additionalProperties: false,
      },
    },
    budget: {
      type: "array",
      items: {
        type: "object",
        properties: {
          category: { type: "string" },
          amountUSD: { type: "integer" },
        },
        required: ["category", "amountUSD"],
        additionalProperties: false,
      },
    },
  },
  required: ["days", "budget"],
  additionalProperties: false,
};

exports.generateItinerary = onCall(
  { secrets: [ANTHROPIC_API_KEY], timeoutSeconds: 120, memory: "512MiB" },
  async (request) => {
    const uid = request.auth && request.auth.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Please sign in to generate an itinerary.");
    }

    const db = admin.firestore();

    // 1. Entitlement — the client mirrors its StoreKit entitlement into
    //    users/{uid}.isPremium; we trust nothing else.
    const userSnap = await db.collection("users").doc(uid).get();
    const isPremium = userSnap.get("isPremium") === true;

    // 2. Allowance — atomic check-and-increment so concurrent calls can't race
    //    past it. Premium: MONTHLY_CAP per month. Free: FREE_LIMIT lifetime.
    const month = new Date().toISOString().slice(0, 7); // e.g. "2026-06"
    const usageRef = db.collection("users").doc(uid).collection("usage").doc("itinerary");
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(usageRef);
      const data = snap.exists ? snap.data() : {};
      if (isPremium) {
        const count = data.month === month ? data.count || 0 : 0;
        if (count >= MONTHLY_CAP) {
          throw new HttpsError("resource-exhausted", "Monthly itinerary limit reached.");
        }
        tx.set(
          usageRef,
          { month, count: count + 1, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
          { merge: true }
        );
      } else {
        const freeUsed = data.freeCount || 0;
        if (freeUsed >= FREE_LIMIT) {
          throw new HttpsError("permission-denied", "Upgrade to Premium for more itineraries.");
        }
        tx.set(
          usageRef,
          { freeCount: freeUsed + 1, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
          { merge: true }
        );
      }
    });

    // 3. Validate input.
    const data = request.data || {};
    const destination = data.destination || {};
    const preferences = data.preferences || {};
    const startDate = typeof data.startDate === "string" ? data.startDate : null;
    const dayCount = Number.isInteger(data.days) && data.days >= 3 && data.days <= 10 ? data.days : 7;
    if (!destination.place) {
      throw new HttpsError("invalid-argument", "A destination is required.");
    }

    // 4. Build the prompt.
    const system =
      "You are an expert romantic-travel planner for couples, with deep, current knowledge of " +
      "destinations worldwide. Create a romantic, specific, and realistic day-by-day " +
      "itinerary tailored to the occasion, the couple's stated tastes, budget, and travel dates. " +
      "Match the length and pacing to the occasion — a short getaway is tighter and more relaxed, " +
      "a honeymoon is more indulgent. " +
      "Be concrete: name real neighbourhoods, kinds of venues, beaches, viewpoints, and " +
      "experiences a couple could actually do there — never generic filler like 'explore the " +
      "highlights'. Lean into romance (sunsets, private moments, special dinners) without being " +
      "cheesy. Pace the days sensibly: arrival/settling on day one, a relaxed farewell on the " +
      "last day. Keep each activity to one or two vivid sentences. For the budget, output the " +
      "lines Flights, Stays, Dining, Experiences, and Everything else as USD integers that sum " +
      "to roughly the indicative total provided.";

    const occasion = data.occasion || {};
    const lines = [];
    if (occasion.descriptor) {
      lines.push(`Trip type: this is ${occasion.descriptor}.`);
      if (occasion.tone) lines.push(`Tone & pacing: ${occasion.tone}`);
    }
    lines.push(`Destination: ${destination.place}${destination.country ? ", " + destination.country : ""}.`);
    if (destination.summary) lines.push(`About: ${destination.summary}`);
    if (destination.region) lines.push(`Region: ${destination.region}.`);
    if (destination.bestSeason) lines.push(`Best season to visit: ${destination.bestSeason}.`);
    if (Array.isArray(destination.highlights) && destination.highlights.length) {
      lines.push(`Known highlights to weave in where they fit: ${destination.highlights.join(", ")}.`);
    }
    if (destination.estBudgetForTwoUSD) {
      lines.push(`Indicative all-in budget for two: about $${destination.estBudgetForTwoUSD} USD.`);
    }
    if (Array.isArray(preferences.interests) && preferences.interests.length) {
      lines.push(`The couple loves: ${preferences.interests.join(", ")}.`);
    }
    if (preferences.budgetBand) lines.push(`Their budget style: ${preferences.budgetBand}.`);
    if (startDate) lines.push(`Travel start date: ${startDate} (factor in the season/weather).`);
    lines.push(`Produce exactly ${dayCount} days.`);

    // 5. Call Claude with structured output.
    const client = new Anthropic({ apiKey: ANTHROPIC_API_KEY.value() });
    let message;
    try {
      message = await client.messages.create({
        model: MODEL,
        max_tokens: 8000,
        system,
        output_config: { format: { type: "json_schema", schema: ITINERARY_SCHEMA } },
        messages: [{ role: "user", content: lines.join("\n") }],
      });
    } catch (err) {
      console.error("Anthropic request failed", err);
      throw new HttpsError("internal", "Could not generate the itinerary right now.");
    }

    if (message.stop_reason === "refusal") {
      throw new HttpsError("internal", "Could not generate the itinerary for this request.");
    }

    const textBlock = (message.content || []).find((b) => b.type === "text");
    if (!textBlock || !textBlock.text) {
      throw new HttpsError("internal", "Empty itinerary response.");
    }

    let parsed;
    try {
      parsed = JSON.parse(textBlock.text);
    } catch (err) {
      console.error("Failed to parse itinerary JSON", err, textBlock.text);
      throw new HttpsError("internal", "Malformed itinerary response.");
    }

    return parsed;
  }
);
