//
//  HoneymoonData.swift
//  Honeymoon
//
//  Created by Phoon Thet Pine on 31/10/23.
//
//  Bundled destination catalog. Doubles as the seed source for the Firestore
//  `destinations` collection and as the offline fallback when Firestore is
//  empty or unreachable. Budget and flight figures are indicative estimates.
//

import Foundation

let honeymoonData: [Destination] = [
    Destination(
        id: "veligandu-maldives", place: "Veligandu", country: "Maldives",
        image: "photo-veligandu-island-maldives",
        latitude: 4.2985220, longitude: 73.0115579,
        summary: "A tiny private island ringed by overwater villas and glass-clear lagoons — the classic barefoot-luxury honeymoon.",
        region: "Asia", tags: ["beach", "luxury", "tropical", "relaxation"],
        bestSeason: "Nov–Apr", estBudgetForTwoUSD: 6800, flightHours: 17, rating: 4.9,
        highlights: ["Overwater villas", "Private sandbank dinner", "Sunset dolphin cruise"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Anantara_Kihavah_-_Aerial_Hero_Shot_2024.jpg/1920px-Anantara_Kihavah_-_Aerial_Hero_Shot_2024.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Diamonds_Thudufushi_Beach_and_Water_Villas%2C_May_2017_-01.jpg/1920px-Diamonds_Thudufushi_Beach_and_Water_Villas%2C_May_2017_-01.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Diamonds_Thudufushi_Beach_and_Water_Villas%2C_May_2017_-10.jpg/1920px-Diamonds_Thudufushi_Beach_and_Water_Villas%2C_May_2017_-10.jpg"
        ]
    ),
    Destination(
        id: "paris-france", place: "Paris", country: "France",
        image: "photo-paris-france",
        latitude: 48.8534951, longitude: 2.3483915,
        summary: "The original city of love — candlelit bistros, the Seine at dusk, and the Eiffel Tower sparkling on the hour.",
        region: "Europe", tags: ["city", "romantic", "culture", "food"],
        bestSeason: "Apr–Jun", estBudgetForTwoUSD: 4200, flightHours: 11, rating: 4.8,
        highlights: ["Seine river cruise", "Montmartre at dawn", "Champagne day trip"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Eiffel_Tower_sunset_skyline_%28Unsplash%29.jpg/1920px-Eiffel_Tower_sunset_skyline_%28Unsplash%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Champ-de-Mars_from_the_Eiffel_Tower_1%2C_Paris_23_August_2013.jpg/1920px-Champ-de-Mars_from_the_Eiffel_Tower_1%2C_Paris_23_August_2013.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Front_de_Seine_as_seen_from_Pont_Mirabeau_140412_1.jpg/1920px-Front_de_Seine_as_seen_from_Pont_Mirabeau_140412_1.jpg"
        ]
    ),
    Destination(
        id: "athens-greece", place: "Athens", country: "Greece",
        image: "photo-athens-greece",
        latitude: 37.9755648, longitude: 23.7348324,
        summary: "Ancient marble ruins above a buzzing modern city, with island ferries to whitewashed coves a short hop away.",
        region: "Europe", tags: ["city", "history", "culture", "beach"],
        bestSeason: "May–Jun", estBudgetForTwoUSD: 3600, flightHours: 12, rating: 4.6,
        highlights: ["Acropolis at sunset", "Plaka tavernas", "Island-hop to the coast"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/1029_Acropolis_of_Athens_in_Greece_at_night_Photo_by_Giles_Laurent.jpg/1920px-1029_Acropolis_of_Athens_in_Greece_at_night_Photo_by_Giles_Laurent.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/20101024_Acropolis_panoramic_view_from_Areopagus_hill_Athens_Greece.jpg/1920px-20101024_Acropolis_panoramic_view_from_Areopagus_hill_Athens_Greece.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Attica_06-13_Athens_50_View_from_Philopappos_-_Acropolis_Hill.jpg/1920px-Attica_06-13_Athens_50_View_from_Philopappos_-_Acropolis_Hill.jpg"
        ]
    ),
    Destination(
        id: "dubai-uae", place: "Dubai", country: "United Arab Emirates",
        image: "photo-dubai-emirates",
        latitude: 25.0742823, longitude: 55.1885387,
        summary: "Glittering skyline, golden desert dunes, and five-star everything — indulgent and effortlessly glamorous.",
        region: "Middle East", tags: ["city", "luxury", "desert", "shopping"],
        bestSeason: "Nov–Mar", estBudgetForTwoUSD: 5200, flightHours: 13, rating: 4.5,
        highlights: ["Desert dune safari", "Burj Khalifa dinner", "Private yacht marina"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Burj_Khalifa_%28worlds_tallest_building%29_and_the_Dubai_skyline_%2825781049892%29.jpg/1920px-Burj_Khalifa_%28worlds_tallest_building%29_and_the_Dubai_skyline_%2825781049892%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Burj_Khalifa_Night_View_01.jpg/1920px-Burj_Khalifa_Night_View_01.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Burj_Khalifa_from_the_sea%2C_Dubai.jpg/1920px-Burj_Khalifa_from_the_sea%2C_Dubai.jpg"
        ]
    ),
    Destination(
        id: "grandcanyon-usa", place: "Grand Canyon", country: "United States of America",
        image: "photo-grandcanyon-usa",
        latitude: 36.0578070, longitude: -112.1281560,
        summary: "One of the planet's great natural wonders — vast, silent, and unforgettable at sunrise and sunset.",
        region: "North America", tags: ["nature", "adventure", "scenic", "outdoors"],
        bestSeason: "Mar–May", estBudgetForTwoUSD: 3800, flightHours: 15, rating: 4.7,
        highlights: ["Rim-edge sunrise", "Helicopter flight", "Stargazing the South Rim"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Grand_Canyon_South_Rim_at_Sunrise.jpg/1920px-Grand_Canyon_South_Rim_at_Sunrise.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Grand_Canyon_South_Rim_at_Sunrise_2.jpg/1920px-Grand_Canyon_South_Rim_at_Sunrise_2.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Grand_Canyon_%28Arizona%2C_USA%29%2C_South_Rim_nahe_Tusayan_--_2012_--_6040.jpg/1920px-Grand_Canyon_%28Arizona%2C_USA%29%2C_South_Rim_nahe_Tusayan_--_2012_--_6040.jpg"
        ]
    ),
    Destination(
        id: "venice-italy", place: "Venice", country: "Italy",
        image: "photo-venice-italy",
        latitude: 45.4046171, longitude: 12.3105232,
        summary: "Floating palaces, hidden canals, and gondola rides at golden hour — impossibly romantic at every turn.",
        region: "Europe", tags: ["city", "romantic", "culture", "food"],
        bestSeason: "Apr–Jun", estBudgetForTwoUSD: 4400, flightHours: 12, rating: 4.7,
        highlights: ["Private gondola ride", "St. Mark's at night", "Murano & Burano day trip"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Canal_Grande_from_Rialto_bridge_SW.jpg/1920px-Canal_Grande_from_Rialto_bridge_SW.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Panorama_of_Canal_Grande_and_Ponte_di_Rialto%2C_Venice_-_September_2017.jpg/1920px-Panorama_of_Canal_Grande_and_Ponte_di_Rialto%2C_Venice_-_September_2017.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Fondaco_dei_Tedeschi_Canal_Grande_Venezia.jpg/1920px-Fondaco_dei_Tedeschi_Canal_Grande_Venezia.jpg"
        ]
    ),
    Destination(
        id: "budapest-hungary", place: "Budapest", country: "Hungary",
        image: "photo-budapest-hungary",
        latitude: 47.4813896, longitude: 19.1457723,
        summary: "Grand riverside architecture and steaming thermal baths, with one of Europe's most beautiful night skylines.",
        region: "Europe", tags: ["city", "culture", "relaxation", "history"],
        bestSeason: "May–Sep", estBudgetForTwoUSD: 3000, flightHours: 13, rating: 4.5,
        highlights: ["Thermal spa baths", "Danube night cruise", "Castle Hill walk"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/1/18/Budapest_Parlament_by_night_WUXGA.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Budapest_parliament_at_night.jpg/1920px-Budapest_parliament_at_night.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Danube_and_Hungarian_Parliament_Building_by_night.jpg/1920px-Danube_and_Hungarian_Parliament_Building_by_night.jpg"
        ]
    ),
    Destination(
        id: "tatras-poland", place: "High Tatras", country: "Poland",
        image: "photo-tatras-poland",
        latitude: 49.1973771, longitude: 20.0707166,
        summary: "Dramatic alpine peaks, mirror lakes, and cosy mountain lodges — a serene escape for outdoorsy couples.",
        region: "Europe", tags: ["nature", "adventure", "mountains", "outdoors"],
        bestSeason: "Jun–Sep", estBudgetForTwoUSD: 2800, flightHours: 13, rating: 4.4,
        highlights: ["Morskie Oko hike", "Cable-car summit", "Lakeside picnic"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Morskie_Oko_o_poranku.jpg/1920px-Morskie_Oko_o_poranku.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Tatra_Rysy_5.jpg/1920px-Tatra_Rysy_5.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Frozen_Morskie_Oko_2019.jpg/1920px-Frozen_Morskie_Oko_2019.jpg"
        ]
    ),
    Destination(
        id: "lakebled-slovenia", place: "Lake Bled", country: "Slovenia",
        image: "photo-lakebled-slovenia",
        latitude: 46.3639132, longitude: 14.0938069,
        summary: "A fairytale island church on an emerald lake beneath a clifftop castle — picture-perfect and peaceful.",
        region: "Europe", tags: ["nature", "romantic", "scenic", "relaxation"],
        bestSeason: "May–Sep", estBudgetForTwoUSD: 3200, flightHours: 13, rating: 4.8,
        highlights: ["Rowboat to the island", "Clifftop castle dinner", "Lakeside cycle"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Bled_Island_%26_Bled_Castle_%281%29.jpg/1920px-Bled_Island_%26_Bled_Castle_%281%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Bled_Island_05.jpg/1920px-Bled_Island_05.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Bled_Island_07.jpg/1920px-Bled_Island_07.jpg"
        ]
    ),
    Destination(
        id: "barcelona-spain", place: "Barcelona", country: "Spain",
        image: "photo-barcelona-spain",
        latitude: 41.3825802, longitude: 2.1770730,
        summary: "Gaudí's dreamlike architecture, golden beaches, and late-night tapas — vibrant, sunny, and full of life.",
        region: "Europe", tags: ["city", "beach", "food", "culture"],
        bestSeason: "May–Jun", estBudgetForTwoUSD: 3800, flightHours: 12, rating: 4.6,
        highlights: ["Sagrada Família", "Beachfront paella", "Park Güell at sunset"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Sagrada_Familia_March_2015-10a.jpg/1920px-Sagrada_Familia_March_2015-10a.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Barcelona_Parc_G%C3%BCell_el_drac.jpg/1920px-Barcelona_Parc_G%C3%BCell_el_drac.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Barcelona_-_Park_G%C3%BCell_-_Antonio_Gaud%C3%AD_-_ICE_Fisheye.jpg/1920px-Barcelona_-_Park_G%C3%BCell_-_Antonio_Gaud%C3%AD_-_ICE_Fisheye.jpg"
        ]
    ),
    Destination(
        id: "sanfrancisco-usa", place: "San Francisco", country: "United States of America",
        image: "photo-sanfrancisco-usa",
        latitude: 37.7879363, longitude: -122.4075201,
        summary: "Foggy bridges, hilly streets, and wine country an hour north — cool, characterful, and effortlessly stylish.",
        region: "North America", tags: ["city", "scenic", "food", "culture"],
        bestSeason: "Sep–Oct", estBudgetForTwoUSD: 4600, flightHours: 14, rating: 4.4,
        highlights: ["Golden Gate cycle", "Napa wine tour", "Bay sunset sail"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Golden_Gate_Bridge_as_seen_from_Marshall%E2%80%99s_Beach%2C_March_2018.jpg/1920px-Golden_Gate_Bridge_as_seen_from_Marshall%E2%80%99s_Beach%2C_March_2018.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Golden_Gate_Bridge_at_sunset_1.jpg/1920px-Golden_Gate_Bridge_at_sunset_1.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/c/c2/Golden_Gate_Bridge_by_night.jpg"
        ]
    ),
    Destination(
        id: "emeraldlake-canada", place: "Emerald Lake", country: "Canada",
        image: "photo-emaraldlake-canada",
        latitude: 51.4428000, longitude: -116.5285000,
        summary: "Vivid turquoise water cradled by snow-dusted Rockies — a tranquil, cinematic wilderness retreat.",
        region: "North America", tags: ["nature", "scenic", "mountains", "relaxation"],
        bestSeason: "Jun–Sep", estBudgetForTwoUSD: 4200, flightHours: 15, rating: 4.8,
        highlights: ["Lakeside lodge cabin", "Canoe the still water", "Rockies scenic drive"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Canoeing_on_Emerald_Lake_in_Yoho_National_Park%2C_BC.jpg/1920px-Canoeing_on_Emerald_Lake_in_Yoho_National_Park%2C_BC.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/Emerald_Lake%2C_Yoho_NP_British_Columbia_Canada_%285988280349%29.jpg/1920px-Emerald_Lake%2C_Yoho_NP_British_Columbia_Canada_%285988280349%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Emerald_lake_Yoho_national_park.jpg/1920px-Emerald_lake_Yoho_national_park.jpg"
        ]
    ),
    Destination(
        id: "krabi-thailand", place: "Krabi", country: "Thailand",
        image: "photo-krabi-thailand",
        latitude: 8.0863000, longitude: 98.9063000,
        summary: "Towering limestone cliffs over warm turquoise seas, hidden lagoons, and long-tail boats to secret beaches.",
        region: "Asia", tags: ["beach", "tropical", "adventure", "relaxation"],
        bestSeason: "Nov–Mar", estBudgetForTwoUSD: 3400, flightHours: 16, rating: 4.6,
        highlights: ["Island long-tail tour", "Railay Beach", "Cliffside spa"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Rai_Leh_Bay.jpg/1920px-Rai_Leh_Bay.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Railay%2C_Krabi%2C_Thailand.jpg/1920px-Railay%2C_Krabi%2C_Thailand.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/Rai_Leh_Beach1.jpg/1920px-Rai_Leh_Beach1.jpg"
        ]
    ),
    Destination(
        id: "rome-italy", place: "Rome", country: "Italy",
        image: "photo-rome-italy",
        latitude: 41.8933203, longitude: 12.4829321,
        summary: "Three thousand years of history on every corner, with long lazy dinners and a fountain to toss a coin in.",
        region: "Europe", tags: ["city", "history", "culture", "food"],
        bestSeason: "Apr–Jun", estBudgetForTwoUSD: 4000, flightHours: 12, rating: 4.7,
        highlights: ["Colosseum tour", "Trevi at dawn", "Trastevere dinner"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ee/Colosseum_and_Via_Sacra_%28Rome%29.jpg/1920px-Colosseum_and_Via_Sacra_%28Rome%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Colosseum_in_Rome%2C_Italy_-_April_2007.jpg/1920px-Colosseum_in_Rome%2C_Italy_-_April_2007.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Colosseum_of_Rome%2C_Italy.jpg/1920px-Colosseum_of_Rome%2C_Italy.jpg"
        ]
    ),
    Destination(
        id: "seoraksan-southkorea", place: "Seoraksan", country: "South Korea",
        image: "photo-seoraksan-southkorea",
        latitude: 38.1340905, longitude: 128.4172172,
        summary: "Mist-wrapped granite peaks and flaming autumn forests, with temples tucked into the valleys below.",
        region: "Asia", tags: ["nature", "mountains", "scenic", "outdoors"],
        bestSeason: "Sep–Nov", estBudgetForTwoUSD: 3600, flightHours: 15, rating: 4.5,
        highlights: ["Autumn foliage hike", "Cable-car ridge views", "Mountain temple visit"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Footbridge_at_Seoraksan_National_Park.jpg/1920px-Footbridge_at_Seoraksan_National_Park.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/Seoraksan_National_Park_05.jpg/1920px-Seoraksan_National_Park_05.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Seoraksan_National_Park_panorama_3.jpg/1920px-Seoraksan_National_Park_panorama_3.jpg"
        ]
    ),
    Destination(
        id: "newyork-usa", place: "New York", country: "USA",
        image: "photo-newyork-usa",
        latitude: 40.7127281, longitude: -74.0060152,
        summary: "The city that never sleeps — rooftop views, Broadway nights, and Central Park strolls hand in hand.",
        region: "North America", tags: ["city", "culture", "food", "shopping"],
        bestSeason: "Sep–Nov", estBudgetForTwoUSD: 5000, flightHours: 14, rating: 4.6,
        highlights: ["Skyline rooftop bar", "Central Park carriage", "Broadway show"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Brooklyn_Bridge_and_the_Lower_Manhattan_skyline_from_Pebble_Beach%2C_New_York.jpg/1920px-Brooklyn_Bridge_and_the_Lower_Manhattan_skyline_from_Pebble_Beach%2C_New_York.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Lower_Manhattan%2C_New_York_skyline_from_Liberty_Island_2021.jpg/1920px-Lower_Manhattan%2C_New_York_skyline_from_Liberty_Island_2021.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Lower_Manhattan_from_Jersey_City_September_2020_panorama.jpg/1920px-Lower_Manhattan_from_Jersey_City_September_2020_panorama.jpg"
        ]
    ),
    Destination(
        id: "tulum-mexico", place: "Tulum", country: "Mexico",
        image: "photo-tulum-mexico",
        latitude: 20.4296470, longitude: -87.6529306,
        summary: "Bohemian beach clubs, cliff-top Mayan ruins, and crystalline cenotes — laid-back and effortlessly cool.",
        region: "North America", tags: ["beach", "tropical", "culture", "relaxation"],
        bestSeason: "Nov–Apr", estBudgetForTwoUSD: 4000, flightHours: 16, rating: 4.5,
        highlights: ["Cenote swim", "Beachfront ruins", "Jungle eco-spa"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Beach_at_Tulum_Ruins_-_panoramio.jpg/1920px-Beach_at_Tulum_Ruins_-_panoramio.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Maya_ruins_at_Tulum_-_Palms_and_beach.jpg/1920px-Maya_ruins_at_Tulum_-_Palms_and_beach.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Maya_ruins_at_Tulum_2023_-_beach.jpg/1920px-Maya_ruins_at_Tulum_2023_-_beach.jpg"
        ]
    ),
    Destination(
        id: "london-uk", place: "London", country: "United Kingdom",
        image: "photo-london-uk",
        latitude: 51.5074456, longitude: -0.1277653,
        summary: "Royal pageantry, world-class theatre, and riverside walks — classic, cosmopolitan, and endlessly engaging.",
        region: "Europe", tags: ["city", "culture", "history", "shopping"],
        bestSeason: "May–Sep", estBudgetForTwoUSD: 4600, flightHours: 11, rating: 4.5,
        highlights: ["Thames evening cruise", "West End show", "Afternoon tea"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/HMS_Belfast_and_Tower_Bridge_before_sunrise.jpg/1920px-HMS_Belfast_and_Tower_Bridge_before_sunrise.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/London%2C_Tower_Bridge_--_2016_--_4676.jpg/1920px-London%2C_Tower_Bridge_--_2016_--_4676.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Tower_Bridge_London_Dusk_Feb_2006.jpg/1920px-Tower_Bridge_London_Dusk_Feb_2006.jpg"
        ]
    ),
    Destination(
        id: "yosemite-usa", place: "Yosemite", country: "USA",
        image: "photo-yosemite-usa",
        latitude: 37.7327236, longitude: -119.6057042,
        summary: "Cathedral granite walls, thundering waterfalls, and giant sequoias — raw, awe-inspiring American wilderness.",
        region: "North America", tags: ["nature", "adventure", "mountains", "outdoors"],
        bestSeason: "May–Sep", estBudgetForTwoUSD: 3800, flightHours: 15, rating: 4.7,
        highlights: ["Glacier Point sunset", "Valley floor cycle", "Sequoia grove walk"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Tunnel_View%2C_Yosemite_Valley%2C_Yosemite_NP_-_Diliff.jpg/1920px-Tunnel_View%2C_Yosemite_Valley%2C_Yosemite_NP_-_Diliff.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Half_Dome_with_Eastern_Yosemite_Valley.jpg/1920px-Half_Dome_with_Eastern_Yosemite_Valley.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Valley_View_Yosemite_August_2013_002.jpg/1920px-Valley_View_Yosemite_August_2013_002.jpg"
        ]
    ),
    Destination(
        id: "riodejaneiro-brazil", place: "Rio de Janeiro", country: "Brazil",
        image: "photo-riodejaneiro-brazil",
        latitude: -22.9110137, longitude: -43.2093727,
        summary: "Samba rhythms, mountain-framed beaches, and Christ the Redeemer watching over it all — joyful and electric.",
        region: "South America", tags: ["beach", "city", "culture", "scenic"],
        bestSeason: "Dec–Mar", estBudgetForTwoUSD: 4400, flightHours: 18, rating: 4.4,
        highlights: ["Sugarloaf cable car", "Copacabana sunset", "Christ the Redeemer"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Christ_the_Redeemer-%28Corcovado%29_front_view.jpg/1920px-Christ_the_Redeemer-%28Corcovado%29_front_view.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Redentor_Over_Clouds_1.jpg/1920px-Redentor_Over_Clouds_1.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Rio_de_Janeiro%2C_Brazil_0011_02.jpg/1920px-Rio_de_Janeiro%2C_Brazil_0011_02.jpg"
        ]
    ),
    Destination(
        id: "sydney-australia", place: "Sydney", country: "Australia",
        image: "photo-sydney-australia",
        latitude: -33.8698439, longitude: 151.2082848,
        summary: "Iconic harbour, golden surf beaches, and a sparkling city — sunny, outdoorsy, and full of good energy.",
        region: "Oceania", tags: ["city", "beach", "scenic", "food"],
        bestSeason: "Oct–Apr", estBudgetForTwoUSD: 5400, flightHours: 22, rating: 4.6,
        highlights: ["Harbour sunset sail", "Bondi coastal walk", "Opera House night"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Sydney_%28AU%29%2C_View_from_Opera_House%2C_Harbour_Bridge_--_2019_--_3070.jpg/1920px-Sydney_%28AU%29%2C_View_from_Opera_House%2C_Harbour_Bridge_--_2019_--_3070.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Sydney_Harbour_Bridge_night.jpg/1920px-Sydney_Harbour_Bridge_night.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/MC_Sydney_Opera_House.jpg/1920px-MC_Sydney_Opera_House.jpg"
        ]
    ),
    Destination(
        id: "santorini-greece", place: "Santorini", country: "Greece",
        image: "photo-santorini-greece",
        latitude: 36.4622122, longitude: 25.3757257,
        summary: "Whitewashed villages clinging to a volcanic caldera, blue-domed churches, and the most famous sunset in the Mediterranean.",
        region: "Europe", tags: ["beach", "romantic", "scenic", "relaxation"],
        bestSeason: "May–Sep", estBudgetForTwoUSD: 4800, flightHours: 13, rating: 4.9,
        highlights: ["Oia sunset", "Caldera cliff villa", "Catamaran lagoon cruise"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Oia_-_Santorini_2019.jpg/1920px-Oia_-_Santorini_2019.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/Oia_Sunset_-_Santorini%2C_Greece_-_August_2008.jpg/1920px-Oia_Sunset_-_Santorini%2C_Greece_-_August_2008.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Oia_Sunset_3.jpg/1920px-Oia_Sunset_3.jpg"
        ]
    ),
    Destination(
        id: "bali-indonesia", place: "Bali", country: "Indonesia",
        image: "photo-bali-indonesia",
        latitude: -8.5170195, longitude: 115.2550507,
        summary: "Emerald rice terraces, jungle temples, and serene spa retreats — a spiritual, romantic escape at gentle prices.",
        region: "Asia", tags: ["tropical", "culture", "relaxation", "nature"],
        bestSeason: "Apr–Oct", estBudgetForTwoUSD: 3200, flightHours: 17, rating: 4.7,
        highlights: ["Tegallalang rice terraces", "Ubud spa day", "Clifftop temple at sunset"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Rice_terraces%2C_Bali.jpg/1920px-Rice_terraces%2C_Bali.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Tegallalang_Rice_Terraces_Bali.jpg/1920px-Tegallalang_Rice_Terraces_Bali.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Tegallalang_Rice_Terraces.jpg/1920px-Tegallalang_Rice_Terraces.jpg"
        ]
    ),
    Destination(
        id: "borabora-frenchpolynesia", place: "Bora Bora", country: "French Polynesia",
        image: "photo-borabora-frenchpolynesia",
        latitude: -16.5043467, longitude: -151.7366886,
        summary: "A turquoise lagoon ringed by overwater bungalows beneath Mount Otemanu — the ultimate South Pacific honeymoon.",
        region: "Oceania", tags: ["beach", "luxury", "tropical", "relaxation"],
        bestSeason: "May–Oct", estBudgetForTwoUSD: 7200, flightHours: 20, rating: 4.9,
        highlights: ["Overwater bungalow", "Lagoon snorkel", "Mount Otemanu views"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Bora_Bora_%2816542797633%29.jpg/1920px-Bora_Bora_%2816542797633%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Bora-Bora_French_Polynesia_-_panoramio_%2823%29.jpg/1920px-Bora-Bora_French_Polynesia_-_panoramio_%2823%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Bora-Bora_French_Polynesia_-_panoramio_%2836%29.jpg/1920px-Bora-Bora_French_Polynesia_-_panoramio_%2836%29.jpg"
        ]
    ),
    Destination(
        id: "kyoto-japan", place: "Kyoto", country: "Japan",
        image: "photo-kyoto-japan",
        latitude: 35.0115754, longitude: 135.7681441,
        summary: "Thousands of vermilion torii gates, lantern-lit geisha streets, and tranquil temple gardens steeped in old Japan.",
        region: "Asia", tags: ["city", "culture", "history", "food"],
        bestSeason: "Mar–May", estBudgetForTwoUSD: 4400, flightHours: 14, rating: 4.8,
        highlights: ["Fushimi Inari gates", "Arashiyama bamboo grove", "Geisha-district dinner"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/2021_Sagano_Bamboo_forest_in_Arashiyama%2C_Kyoto%2C_Japan.jpg/1920px-2021_Sagano_Bamboo_forest_in_Arashiyama%2C_Kyoto%2C_Japan.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/KyotoFushimiInariLarge.jpg/1920px-KyotoFushimiInariLarge.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Fushimi_Inari-taisha%2C_Kyoto%2C_20240818_1343_4411.jpg/1920px-Fushimi_Inari-taisha%2C_Kyoto%2C_20240818_1343_4411.jpg"
        ]
    ),
    Destination(
        id: "amalfi-italy", place: "Amalfi Coast", country: "Italy",
        image: "photo-amalfi-italy",
        latitude: 40.6286581, longitude: 14.4854955,
        summary: "Pastel villages tumbling down cliffs to the sea, lemon groves, and long lazy lunches above the bluest water.",
        region: "Europe", tags: ["beach", "romantic", "scenic", "food"],
        bestSeason: "May–Sep", estBudgetForTwoUSD: 5000, flightHours: 12, rating: 4.8,
        highlights: ["Positano beach club", "Coastal boat day", "Ravello garden terrace"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Positano%2C_Amalfi_Coast%2C_Italy_%2822286060906%29.jpg/1920px-Positano%2C_Amalfi_Coast%2C_Italy_%2822286060906%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Positano_%28Italy%29_02.jpg/1920px-Positano_%28Italy%29_02.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Amalfi_vista_dal_mare_2_Campania.jpg/1920px-Amalfi_vista_dal_mare_2_Campania.jpg"
        ]
    ),
    Destination(
        id: "maui-usa", place: "Maui", country: "USA",
        image: "photo-maui-usa",
        latitude: 20.8871774, longitude: -156.6748024,
        summary: "Golden beaches, the winding Road to Hāna, and sunrise above the clouds on Haleakalā — laid-back island romance.",
        region: "North America", tags: ["beach", "tropical", "nature", "relaxation"],
        bestSeason: "Apr–Oct", estBudgetForTwoUSD: 5600, flightHours: 18, rating: 4.7,
        highlights: ["Road to Hāna", "Haleakalā sunrise", "Snorkel at Molokini"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Hawaii_Maui_Maluaka_Beach_%2822028601953%29.jpg/1920px-Hawaii_Maui_Maluaka_Beach_%2822028601953%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Oneuli_Beach_Maui_Hawaii_%2831869255618%29.jpg/1920px-Oneuli_Beach_Maui_Hawaii_%2831869255618%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Kaihalulu_Red_Sand_Beach.JPG/1920px-Kaihalulu_Red_Sand_Beach.JPG"
        ]
    ),
    Destination(
        id: "queenstown-newzealand", place: "Queenstown", country: "New Zealand",
        image: "photo-queenstown-newzealand",
        latitude: -45.0321923, longitude: 168.661,
        summary: "An adventure capital cradled by alpine peaks and a mirror-still lake — thrills by day, cosy lakeside nights.",
        region: "Oceania", tags: ["nature", "adventure", "mountains", "scenic"],
        bestSeason: "Dec–Mar", estBudgetForTwoUSD: 5200, flightHours: 21, rating: 4.7,
        highlights: ["Skyline gondola", "Milford Sound day trip", "Lakeside wine tasting"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Shore_of_the_Lake_Wakatipu_in_Queenstown_03.jpg/1920px-Shore_of_the_Lake_Wakatipu_in_Queenstown_03.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Landscape_of_Queenstown-Lakes_District.jpg/1920px-Landscape_of_Queenstown-Lakes_District.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Arrow_Junction%2C_Crown_Ranges%2C_Queenstown_District%2C_New_Zealand.jpg/1920px-Arrow_Junction%2C_Crown_Ranges%2C_Queenstown_District%2C_New_Zealand.jpg"
        ]
    ),
    Destination(
        id: "capetown-southafrica", place: "Cape Town", country: "South Africa",
        image: "photo-capetown-southafrica",
        latitude: -33.9288301, longitude: 18.4172197,
        summary: "Where Table Mountain meets two oceans — beaches, vineyards, and penguins all within one stunning city.",
        region: "Africa", tags: ["city", "nature", "scenic", "food"],
        bestSeason: "Nov–Mar", estBudgetForTwoUSD: 3800, flightHours: 16, rating: 4.6,
        highlights: ["Table Mountain cableway", "Cape Winelands tour", "Boulders Beach penguins"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Cape_Town_%28ZA%29%2C_Table_Mountain_--_2024_--_2822.jpg/1920px-Cape_Town_%28ZA%29%2C_Table_Mountain_--_2024_--_2822.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Cape_Town_%28ZA%29%2C_Table_Mountain_--_2024_--_2825.jpg/1920px-Cape_Town_%28ZA%29%2C_Table_Mountain_--_2024_--_2825.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Cape_Town_%28ZA%29%2C_Table_Mountain_--_2024_--_3437.jpg/1920px-Cape_Town_%28ZA%29%2C_Table_Mountain_--_2024_--_3437.jpg"
        ]
    ),
    Destination(
        id: "reykjavik-iceland", place: "Reykjavík", country: "Iceland",
        image: "photo-reykjavik-iceland",
        latitude: 64.145981, longitude: -21.9422367,
        summary: "Thundering waterfalls, glacier lagoons, and dancing northern lights across a raw volcanic wilderness.",
        region: "Europe", tags: ["nature", "adventure", "scenic", "outdoors"],
        bestSeason: "Sep–Mar", estBudgetForTwoUSD: 5400, flightHours: 13, rating: 4.8,
        highlights: ["Golden Circle drive", "Blue Lagoon soak", "Northern lights hunt"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Sk%C3%B3gafoss_July_2014.JPG/1920px-Sk%C3%B3gafoss_July_2014.JPG",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/Jokulsarlon_Panorama.jpg/1920px-Jokulsarlon_Panorama.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Kirkjufell_in_winter.jpg/1920px-Kirkjufell_in_winter.jpg"
        ]
    ),
    Destination(
        id: "marrakech-morocco", place: "Marrakech", country: "Morocco",
        image: "photo-marrakech-morocco",
        latitude: 31.6258257, longitude: -7.9891608,
        summary: "A sensory rush of spice-scented souks, hidden riad courtyards, and palm groves at the edge of the Sahara.",
        region: "Africa", tags: ["city", "culture", "history", "shopping"],
        bestSeason: "Oct–Apr", estBudgetForTwoUSD: 3000, flightHours: 13, rating: 4.5,
        highlights: ["Jemaa el-Fnaa at dusk", "Jardin Majorelle", "Atlas Mountains day trip"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Jemaa_El_Fnaa_-_panoramio.jpg/1920px-Jemaa_El_Fnaa_-_panoramio.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Jardin_Majorelle_in_Marrakesch_05.jpg/1920px-Jardin_Majorelle_in_Marrakesch_05.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Jemaa_el-Fnaa_at_night.jpg/1920px-Jemaa_el-Fnaa_at_night.jpg"
        ]
    ),
    Destination(
        id: "lucerne-switzerland", place: "Lucerne", country: "Switzerland",
        image: "photo-lucerne-switzerland",
        latitude: 47.052144, longitude: 8.3058123,
        summary: "A medieval covered bridge over a turquoise river, a glittering lake, and snow-capped peaks rising straight from the shore.",
        region: "Europe", tags: ["city", "scenic", "romantic", "nature"],
        bestSeason: "May–Sep", estBudgetForTwoUSD: 5400, flightHours: 12, rating: 4.7,
        highlights: ["Chapel Bridge stroll", "Lake Lucerne cruise", "Mt Pilatus cable car"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Chapel_Bridge_and_view_of_Pilatus%2C_Lucerne%2C_Switzerland-LCCN2001703043.jpg/1920px-Chapel_Bridge_and_view_of_Pilatus%2C_Lucerne%2C_Switzerland-LCCN2001703043.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Luzern_-_Chapel_Bridge_-_March_2019_%2802%29.jpg/1920px-Luzern_-_Chapel_Bridge_-_March_2019_%2802%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Luzern_Kapellbruecke.jpg/1920px-Luzern_Kapellbruecke.jpg"
        ]
    ),
    Destination(
        id: "machupicchu-peru", place: "Machu Picchu", country: "Peru",
        image: "photo-machupicchu-peru",
        latitude: -13.164341, longitude: -72.5450094,
        summary: "A lost Inca city of terraced stone wrapped in cloud forest and jagged green peaks — awe-inspiring and deeply romantic.",
        region: "South America", tags: ["history", "adventure", "scenic", "nature"],
        bestSeason: "May–Sep", estBudgetForTwoUSD: 4600, flightHours: 19, rating: 4.9,
        highlights: ["Sunrise at the citadel", "Huayna Picchu climb", "Sacred Valley train"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/99_-_Machu_Picchu_-_Juin_2009.edit3.jpg/1920px-99_-_Machu_Picchu_-_Juin_2009.edit3.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/80_-_Machu_Picchu_-_Juin_2009_-_edit.jpg/1920px-80_-_Machu_Picchu_-_Juin_2009_-_edit.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Machu_Picchu%2C_Per%C3%BA%2C_2015-07-30%2C_DD_60.JPG/1920px-Machu_Picchu%2C_Per%C3%BA%2C_2015-07-30%2C_DD_60.JPG"
        ]
    ),
    Destination(
        id: "banff-canada", place: "Banff", country: "Canada",
        image: "photo-banff-canada",
        latitude: 51.175076, longitude: -115.5720773,
        summary: "Impossibly blue glacial lakes cradled by the Canadian Rockies, with cosy lodges and wildlife at every turn.",
        region: "North America", tags: ["nature", "scenic", "mountains", "outdoors"],
        bestSeason: "Jun–Sep", estBudgetForTwoUSD: 4400, flightHours: 15, rating: 4.8,
        highlights: ["Moraine Lake canoe", "Lake Louise stroll", "Gondola summit views"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Lake_Moraine-Banff_National_Park.jpg/1920px-Lake_Moraine-Banff_National_Park.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/1_moraine_lake_pano_2019.jpg/1920px-1_moraine_lake_pano_2019.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Moraine_Lake_17092005.jpg/1920px-Moraine_Lake_17092005.jpg"
        ]
    ),
    Destination(
        id: "fiji-islands", place: "Fiji", country: "Fiji",
        image: "photo-fiji-islands",
        latitude: -17.7495601, longitude: 177.1706455,
        summary: "Soft white sand, warm coral lagoons, and famously gentle island hospitality across hundreds of palm-fringed isles.",
        region: "Oceania", tags: ["beach", "tropical", "luxury", "relaxation"],
        bestSeason: "May–Oct", estBudgetForTwoUSD: 6000, flightHours: 19, rating: 4.8,
        highlights: ["Private island resort", "Coral reef snorkel", "Sunset sandbar dinner"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Beach_on_Naviti_island%2C_Yasawa_Islands%2C_Fiji_%282%29_-_August_2016.jpg/1920px-Beach_on_Naviti_island%2C_Yasawa_Islands%2C_Fiji_%282%29_-_August_2016.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Sunset_on_the_beach_Fiji.jpg/1920px-Sunset_on_the_beach_Fiji.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Fiji_Yasawa_Group_-_panoramio.jpg/1920px-Fiji_Yasawa_Group_-_panoramio.jpg"
        ]
    ),
    Destination(
        id: "prague-czech", place: "Prague", country: "Czech Republic",
        image: "photo-prague-czech",
        latitude: 50.0874654, longitude: 14.4212535,
        summary: "A storybook city of spires, cobbled lanes, and a candlelit bridge over the Vltava — fairytale romance at gentle prices.",
        region: "Europe", tags: ["city", "culture", "history", "romantic"],
        bestSeason: "Apr–Jun", estBudgetForTwoUSD: 3400, flightHours: 13, rating: 4.7,
        highlights: ["Charles Bridge at dawn", "Old Town Square", "Castle district walk"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Prague_skyline_at_dawn.jpg/1920px-Prague_skyline_at_dawn.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Prague_07-2016_View_from_Petrinska_Tower_img2.jpg/1920px-Prague_07-2016_View_from_Petrinska_Tower_img2.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/North_view_of_Charles_Bridge_from_M%C3%A1nes%C5%AFv_most%2C_Prague_20160808_1.jpg/1920px-North_view_of_Charles_Bridge_from_M%C3%A1nes%C5%AFv_most%2C_Prague_20160808_1.jpg"
        ]
    ),
    Destination(
        id: "petra-jordan", place: "Petra", country: "Jordan",
        image: "photo-petra-jordan",
        latitude: 30.3258363, longitude: 35.4745669,
        summary: "A rose-red city carved into desert canyons two thousand years ago — one of the world's most breathtaking wonders.",
        region: "Middle East", tags: ["history", "adventure", "desert", "culture"],
        bestSeason: "Mar–May", estBudgetForTwoUSD: 4200, flightHours: 14, rating: 4.8,
        highlights: ["The Treasury reveal", "Petra by candlelight", "Monastery hike"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Petra_%2C_Al-Khazneh_2.jpg/1920px-Petra_%2C_Al-Khazneh_2.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Petra_Jordan_BW_0.jpg/1920px-Petra_Jordan_BW_0.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Petra_Jordan_BW_43.JPG/1920px-Petra_Jordan_BW_43.JPG"
        ]
    ),
    Destination(
        id: "mauritius-island", place: "Mauritius", country: "Mauritius",
        image: "photo-mauritius-island",
        latitude: -20.2759451, longitude: 57.5703566,
        summary: "Turquoise lagoons, powder beaches beneath a dramatic peak, and barefoot luxury in the heart of the Indian Ocean.",
        region: "Africa", tags: ["beach", "luxury", "tropical", "relaxation"],
        bestSeason: "May–Dec", estBudgetForTwoUSD: 6200, flightHours: 18, rating: 4.7,
        highlights: ["Le Morne lagoon", "Catamaran to the reef", "Sunset over the peninsula"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Boat_at_Le_Morne_Beach%2C_Mauritius_%2853697783276%29.jpg/1920px-Boat_at_Le_Morne_Beach%2C_Mauritius_%2853697783276%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/Le_Morne_Beach_Mauritius_%2853698222865%29.jpg/1920px-Le_Morne_Beach_Mauritius_%2853698222865%29.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Le_Morne_Beach_and_Peninsula_in_Mauritius_%2853697990808%29.jpg/1920px-Le_Morne_Beach_and_Peninsula_in_Mauritius_%2853697990808%29.jpg"
        ]
    ),
    Destination(
        id: "halongbay-vietnam", place: "Hạ Long Bay", country: "Vietnam",
        image: "photo-halongbay-vietnam",
        latitude: 20.9084384, longitude: 107.0682782,
        summary: "Thousands of limestone islands rising from emerald water, explored by traditional junk boat — serene and otherworldly.",
        region: "Asia", tags: ["nature", "scenic", "relaxation", "adventure"],
        bestSeason: "Oct–Apr", estBudgetForTwoUSD: 3200, flightHours: 16, rating: 4.6,
        highlights: ["Overnight junk cruise", "Kayak the karsts", "Sunset on deck"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Ha_Long_Bay%2C_Vietnam%2C_Sunset_in_Ha_Long_Bay_2.jpg/1920px-Ha_Long_Bay%2C_Vietnam%2C_Sunset_in_Ha_Long_Bay_2.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Ha_Long_Bay%2C_Vietnam%2C_Fishing_boat.jpg/1920px-Ha_Long_Bay%2C_Vietnam%2C_Fishing_boat.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Ha_Long_Bay%2C_Vietnam%2C_View_from_above.jpg/1920px-Ha_Long_Bay%2C_Vietnam%2C_View_from_above.jpg"
        ]
    ),
    Destination(
        id: "zanzibar-tanzania", place: "Zanzibar", country: "Tanzania",
        image: "photo-zanzibar-tanzania",
        latitude: -6.1626528, longitude: 39.1896552,
        summary: "Powder-white beaches and turquoise water meet a spice-scented old town of carved doors and winding lanes.",
        region: "Africa", tags: ["beach", "tropical", "culture", "relaxation"],
        bestSeason: "Jun–Oct", estBudgetForTwoUSD: 4000, flightHours: 17, rating: 4.6,
        highlights: ["Nungwi beach days", "Stone Town spice tour", "Sunset dhow sail"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Nungwi_Beach_Zanzibar.jpg/1920px-Nungwi_Beach_Zanzibar.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Nungwi%2CZanzibar_-_panoramio.jpg/1920px-Nungwi%2CZanzibar_-_panoramio.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Departamento_de_museos_y_antig%C3%BCedades%2C_Stone_Town%2C_Zanz%C3%ADbar%2C_Tanzania%2C_2024-05-31%2C_DD_33-35_HDR.jpg/1920px-Departamento_de_museos_y_antig%C3%BCedades%2C_Stone_Town%2C_Zanz%C3%ADbar%2C_Tanzania%2C_2024-05-31%2C_DD_33-35_HDR.jpg"
        ]
    ),
    Destination(
        id: "dubrovnik-croatia", place: "Dubrovnik", country: "Croatia",
        image: "photo-dubrovnik-croatia",
        latitude: 42.6491029, longitude: 18.0939501,
        summary: "A honey-stoned walled city above the sparkling Adriatic — marble streets, sea-cliff bars, and islands just offshore.",
        region: "Europe", tags: ["city", "beach", "history", "scenic"],
        bestSeason: "May–Sep", estBudgetForTwoUSD: 4200, flightHours: 13, rating: 4.7,
        highlights: ["Walk the city walls", "Cable car at sunset", "Island boat day"],
        gallery: [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Dubrovnik_Old_Town_1.jpg/1920px-Dubrovnik_Old_Town_1.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Dubrovnik_Old_Town_2.jpg/1920px-Dubrovnik_Old_Town_2.jpg",
            "https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/Dubrovnik_Old_Town_3.jpg/1920px-Dubrovnik_Old_Town_3.jpg"
        ]
    )
]
