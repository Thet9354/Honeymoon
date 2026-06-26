// Seeds the Firestore `destinations` collection from the bundled catalog.
// Uses the Firebase Admin SDK with a service-account key, which bypasses
// security rules — so the client-facing read-only rule stays untouched.
//
// Usage (see README.md): place serviceAccountKey.json in this folder, then:
//   npm install
//   node seed-destinations.mjs
//
// Re-running is safe: docs are keyed by id and overwritten (merge), so this
// also works as an "update content" step later.

import { initializeApp, cert } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const serviceAccount = JSON.parse(
  readFileSync(join(here, "serviceAccountKey.json"), "utf8")
);

initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();

// Mirror of Honeymoon/Data/HoneymoonData.swift. Keep in sync when either changes.
const destinations = [
  { id: "veligandu-maldives", place: "Veligandu", country: "Maldives", image: "photo-veligandu-island-maldives", summary: "A tiny private island ringed by overwater villas and glass-clear lagoons — the classic barefoot-luxury honeymoon.", region: "Asia", tags: ["beach", "luxury", "tropical", "relaxation"], bestSeason: "Nov–Apr", estBudgetForTwoUSD: 6800, flightHours: 17, rating: 4.9, highlights: ["Overwater villas", "Private sandbank dinner", "Sunset dolphin cruise"] },
  { id: "paris-france", place: "Paris", country: "France", image: "photo-paris-france", summary: "The original city of love — candlelit bistros, the Seine at dusk, and the Eiffel Tower sparkling on the hour.", region: "Europe", tags: ["city", "romantic", "culture", "food"], bestSeason: "Apr–Jun", estBudgetForTwoUSD: 4200, flightHours: 11, rating: 4.8, highlights: ["Seine river cruise", "Montmartre at dawn", "Champagne day trip"] },
  { id: "athens-greece", place: "Athens", country: "Greece", image: "photo-athens-greece", summary: "Ancient marble ruins above a buzzing modern city, with island ferries to whitewashed coves a short hop away.", region: "Europe", tags: ["city", "history", "culture", "beach"], bestSeason: "May–Jun", estBudgetForTwoUSD: 3600, flightHours: 12, rating: 4.6, highlights: ["Acropolis at sunset", "Plaka tavernas", "Island-hop to the coast"] },
  { id: "dubai-uae", place: "Dubai", country: "United Arab Emirates", image: "photo-dubai-emirates", summary: "Glittering skyline, golden desert dunes, and five-star everything — indulgent and effortlessly glamorous.", region: "Middle East", tags: ["city", "luxury", "desert", "shopping"], bestSeason: "Nov–Mar", estBudgetForTwoUSD: 5200, flightHours: 13, rating: 4.5, highlights: ["Desert dune safari", "Burj Khalifa dinner", "Private yacht marina"] },
  { id: "grandcanyon-usa", place: "Grand Canyon", country: "United States of America", image: "photo-grandcanyon-usa", summary: "One of the planet's great natural wonders — vast, silent, and unforgettable at sunrise and sunset.", region: "North America", tags: ["nature", "adventure", "scenic", "outdoors"], bestSeason: "Mar–May", estBudgetForTwoUSD: 3800, flightHours: 15, rating: 4.7, highlights: ["Rim-edge sunrise", "Helicopter flight", "Stargazing the South Rim"] },
  { id: "venice-italy", place: "Venice", country: "Italy", image: "photo-venice-italy", summary: "Floating palaces, hidden canals, and gondola rides at golden hour — impossibly romantic at every turn.", region: "Europe", tags: ["city", "romantic", "culture", "food"], bestSeason: "Apr–Jun", estBudgetForTwoUSD: 4400, flightHours: 12, rating: 4.7, highlights: ["Private gondola ride", "St. Mark's at night", "Murano & Burano day trip"] },
  { id: "budapest-hungary", place: "Budapest", country: "Hungary", image: "photo-budapest-hungary", summary: "Grand riverside architecture and steaming thermal baths, with one of Europe's most beautiful night skylines.", region: "Europe", tags: ["city", "culture", "relaxation", "history"], bestSeason: "May–Sep", estBudgetForTwoUSD: 3000, flightHours: 13, rating: 4.5, highlights: ["Thermal spa baths", "Danube night cruise", "Castle Hill walk"] },
  { id: "tatras-poland", place: "High Tatras", country: "Poland", image: "photo-tatras-poland", summary: "Dramatic alpine peaks, mirror lakes, and cosy mountain lodges — a serene escape for outdoorsy couples.", region: "Europe", tags: ["nature", "adventure", "mountains", "outdoors"], bestSeason: "Jun–Sep", estBudgetForTwoUSD: 2800, flightHours: 13, rating: 4.4, highlights: ["Morskie Oko hike", "Cable-car summit", "Lakeside picnic"] },
  { id: "lakebled-slovenia", place: "Lake Bled", country: "Slovenia", image: "photo-lakebled-slovenia", summary: "A fairytale island church on an emerald lake beneath a clifftop castle — picture-perfect and peaceful.", region: "Europe", tags: ["nature", "romantic", "scenic", "relaxation"], bestSeason: "May–Sep", estBudgetForTwoUSD: 3200, flightHours: 13, rating: 4.8, highlights: ["Rowboat to the island", "Clifftop castle dinner", "Lakeside cycle"] },
  { id: "barcelona-spain", place: "Barcelona", country: "Spain", image: "photo-barcelona-spain", summary: "Gaudí's dreamlike architecture, golden beaches, and late-night tapas — vibrant, sunny, and full of life.", region: "Europe", tags: ["city", "beach", "food", "culture"], bestSeason: "May–Jun", estBudgetForTwoUSD: 3800, flightHours: 12, rating: 4.6, highlights: ["Sagrada Família", "Beachfront paella", "Park Güell at sunset"] },
  { id: "sanfrancisco-usa", place: "San Francisco", country: "United States of America", image: "photo-sanfrancisco-usa", summary: "Foggy bridges, hilly streets, and wine country an hour north — cool, characterful, and effortlessly stylish.", region: "North America", tags: ["city", "scenic", "food", "culture"], bestSeason: "Sep–Oct", estBudgetForTwoUSD: 4600, flightHours: 14, rating: 4.4, highlights: ["Golden Gate cycle", "Napa wine tour", "Bay sunset sail"] },
  { id: "emeraldlake-canada", place: "Emerald Lake", country: "Canada", image: "photo-emaraldlake-canada", summary: "Vivid turquoise water cradled by snow-dusted Rockies — a tranquil, cinematic wilderness retreat.", region: "North America", tags: ["nature", "scenic", "mountains", "relaxation"], bestSeason: "Jun–Sep", estBudgetForTwoUSD: 4200, flightHours: 15, rating: 4.8, highlights: ["Lakeside lodge cabin", "Canoe the still water", "Rockies scenic drive"] },
  { id: "krabi-thailand", place: "Krabi", country: "Thailand", image: "photo-krabi-thailand", summary: "Towering limestone cliffs over warm turquoise seas, hidden lagoons, and long-tail boats to secret beaches.", region: "Asia", tags: ["beach", "tropical", "adventure", "relaxation"], bestSeason: "Nov–Mar", estBudgetForTwoUSD: 3400, flightHours: 16, rating: 4.6, highlights: ["Island long-tail tour", "Railay Beach", "Cliffside spa"] },
  { id: "rome-italy", place: "Rome", country: "Italy", image: "photo-rome-italy", summary: "Three thousand years of history on every corner, with long lazy dinners and a fountain to toss a coin in.", region: "Europe", tags: ["city", "history", "culture", "food"], bestSeason: "Apr–Jun", estBudgetForTwoUSD: 4000, flightHours: 12, rating: 4.7, highlights: ["Colosseum tour", "Trevi at dawn", "Trastevere dinner"] },
  { id: "seoraksan-southkorea", place: "Seoraksan", country: "South Korea", image: "photo-seoraksan-southkorea", summary: "Mist-wrapped granite peaks and flaming autumn forests, with temples tucked into the valleys below.", region: "Asia", tags: ["nature", "mountains", "scenic", "outdoors"], bestSeason: "Sep–Nov", estBudgetForTwoUSD: 3600, flightHours: 15, rating: 4.5, highlights: ["Autumn foliage hike", "Cable-car ridge views", "Mountain temple visit"] },
  { id: "newyork-usa", place: "New York", country: "USA", image: "photo-newyork-usa", summary: "The city that never sleeps — rooftop views, Broadway nights, and Central Park strolls hand in hand.", region: "North America", tags: ["city", "culture", "food", "shopping"], bestSeason: "Sep–Nov", estBudgetForTwoUSD: 5000, flightHours: 14, rating: 4.6, highlights: ["Skyline rooftop bar", "Central Park carriage", "Broadway show"] },
  { id: "tulum-mexico", place: "Tulum", country: "Mexico", image: "photo-tulum-mexico", summary: "Bohemian beach clubs, cliff-top Mayan ruins, and crystalline cenotes — laid-back and effortlessly cool.", region: "North America", tags: ["beach", "tropical", "culture", "relaxation"], bestSeason: "Nov–Apr", estBudgetForTwoUSD: 4000, flightHours: 16, rating: 4.5, highlights: ["Cenote swim", "Beachfront ruins", "Jungle eco-spa"] },
  { id: "london-uk", place: "London", country: "United Kingdom", image: "photo-london-uk", summary: "Royal pageantry, world-class theatre, and riverside walks — classic, cosmopolitan, and endlessly engaging.", region: "Europe", tags: ["city", "culture", "history", "shopping"], bestSeason: "May–Sep", estBudgetForTwoUSD: 4600, flightHours: 11, rating: 4.5, highlights: ["Thames evening cruise", "West End show", "Afternoon tea"] },
  { id: "yosemite-usa", place: "Yosemite", country: "USA", image: "photo-yosemite-usa", summary: "Cathedral granite walls, thundering waterfalls, and giant sequoias — raw, awe-inspiring American wilderness.", region: "North America", tags: ["nature", "adventure", "mountains", "outdoors"], bestSeason: "May–Sep", estBudgetForTwoUSD: 3800, flightHours: 15, rating: 4.7, highlights: ["Glacier Point sunset", "Valley floor cycle", "Sequoia grove walk"] },
  { id: "riodejaneiro-brazil", place: "Rio de Janeiro", country: "Brazil", image: "photo-riodejaneiro-brazil", summary: "Samba rhythms, mountain-framed beaches, and Christ the Redeemer watching over it all — joyful and electric.", region: "South America", tags: ["beach", "city", "culture", "scenic"], bestSeason: "Dec–Mar", estBudgetForTwoUSD: 4400, flightHours: 18, rating: 4.4, highlights: ["Sugarloaf cable car", "Copacabana sunset", "Christ the Redeemer"] },
  { id: "sydney-australia", place: "Sydney", country: "Australia", image: "photo-sydney-australia", summary: "Iconic harbour, golden surf beaches, and a sparkling city — sunny, outdoorsy, and full of good energy.", region: "Oceania", tags: ["city", "beach", "scenic", "food"], bestSeason: "Oct–Apr", estBudgetForTwoUSD: 5400, flightHours: 22, rating: 4.6, highlights: ["Harbour sunset sail", "Bondi coastal walk", "Opera House night"] },
];

async function main() {
  const batch = db.batch();
  for (const d of destinations) {
    batch.set(db.collection("destinations").doc(d.id), d, { merge: true });
  }
  await batch.commit();
  console.log(`✅ Seeded ${destinations.length} destinations to Firestore.`);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Seeding failed:", err);
    process.exit(1);
  });
