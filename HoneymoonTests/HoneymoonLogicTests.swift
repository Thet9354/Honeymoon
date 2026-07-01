//
//  HoneymoonLogicTests.swift
//  HoneymoonTests
//
//  Baseline unit tests for the app's pure logic — the pieces most worth guarding
//  against regressions: preference ranking, occasion tailoring, budget bands,
//  the deterministic itinerary generator, currency math, photo classification,
//  and weather-code mapping. No Firebase or UI is touched.
//

import XCTest
@testable import Honeymoon

final class HoneymoonLogicTests: XCTestCase {

    // MARK: - Helpers

    private func makeDestination(
        id: String,
        region: String = "",
        tags: [String] = [],
        budget: Int = 0,
        flightHours: Int = 0,
        rating: Double = 0,
        image: String = "img",
        gallery: [String] = []
    ) -> Destination {
        Destination(
            id: id, place: id.capitalized, country: "Country", image: image,
            region: region, tags: tags,
            estBudgetForTwoUSD: budget, flightHours: flightHours, rating: rating,
            gallery: gallery
        )
    }

    // MARK: - BudgetBand

    func testBudgetBandBoundaries() {
        XCTAssertTrue(BudgetBand.budget.contains(3499))
        XCTAssertFalse(BudgetBand.budget.contains(3500))   // upper bound is exclusive
        XCTAssertFalse(BudgetBand.budget.contains(0))       // must be > 0
        XCTAssertTrue(BudgetBand.mid.contains(3500))
        XCTAssertTrue(BudgetBand.mid.contains(4999))
        XCTAssertFalse(BudgetBand.mid.contains(5000))
        XCTAssertTrue(BudgetBand.luxury.contains(5000))
        XCTAssertTrue(BudgetBand.luxury.contains(9000))
    }

    // MARK: - TripOccasion

    func testTripOccasionDefaults() {
        XCTAssertEqual(TripOccasion.allCases.count, 4)
        XCTAssertEqual(TripOccasion.getaway.defaultTripDays, 3)
        XCTAssertEqual(TripOccasion.anniversary.defaultTripDays, 5)
        XCTAssertEqual(TripOccasion.babymoon.defaultTripDays, 6)
        XCTAssertEqual(TripOccasion.honeymoon.defaultTripDays, 7)
        // Each occasion carries non-empty AI/copy strings.
        for occasion in TripOccasion.allCases {
            XCTAssertFalse(occasion.planDescriptor.isEmpty)
            XCTAssertFalse(occasion.toneGuidance.isEmpty)
            XCTAssertFalse(occasion.itineraryNoun.isEmpty)
        }
    }

    // MARK: - Ranking

    func testRankingPrefersInterestAndRegionMatches() {
        let beach = makeDestination(id: "beach", region: "Asia", tags: ["beach", "tropical"], budget: 3000)
        let city  = makeDestination(id: "city", region: "Europe", tags: ["city"], budget: 6000)

        var prefs = TravelPreferences()
        prefs.interests = [.beaches]
        prefs.regions = ["Asia"]

        let ranked = prefs.ranked([city, beach])
        XCTAssertEqual(ranked.first?.id, "beach")
    }

    func testEmptyPreferencesPreserveOrder() {
        let a = makeDestination(id: "a")
        let b = makeDestination(id: "b")
        let prefs = TravelPreferences()
        XCTAssertEqual(prefs.ranked([a, b]).map(\.id), ["a", "b"])
    }

    func testGetawayFavoursShorterFlights() {
        let near = makeDestination(id: "near", flightHours: 11)
        let far  = makeDestination(id: "far", flightHours: 20)

        var prefs = TravelPreferences()
        prefs.occasion = .getaway   // only signal — ranking must still run

        let ranked = prefs.ranked([far, near])
        XCTAssertEqual(ranked.first?.id, "near")
    }

    func testHoneymoonDoesNotReorderByFlightAlone() {
        let near = makeDestination(id: "near", flightHours: 11)
        let far  = makeDestination(id: "far", flightHours: 20)

        var prefs = TravelPreferences()
        prefs.occasion = .honeymoon   // no flight weighting, no other signal

        // isEmpty (ignoring occasion) → order preserved.
        XCTAssertEqual(prefs.ranked([far, near]).map(\.id), ["far", "near"])
    }

    // MARK: - Itinerary generator

    func testItineraryDayCountAndShape() {
        let dest = makeDestination(id: "x", budget: 1000, gallery: [])
        let plan = Itinerary.generate(for: dest, days: 3)
        XCTAssertEqual(plan.days.count, 3)
        XCTAssertEqual(plan.days.first?.title, "Arrival & first evening")
        XCTAssertTrue(plan.days.last?.title.contains("Farewell") == true)
        XCTAssertEqual(plan.days.map(\.dayNumber), [1, 2, 3])
    }

    func testItineraryBudgetSplit() {
        let dest = makeDestination(id: "x", budget: 1000)
        let plan = Itinerary.generate(for: dest, days: 5)
        XCTAssertEqual(plan.budget.map(\.category),
                       ["Flights", "Stays", "Dining", "Experiences", "Everything else"])
        let total = plan.budget.reduce(0) { $0 + $1.amountUSD }
        XCTAssertEqual(total, 1000, accuracy: 2)   // rounding tolerance
    }

    func testItineraryNoBudgetWhenUnknown() {
        let dest = makeDestination(id: "x", budget: 0)
        XCTAssertTrue(Itinerary.generate(for: dest, days: 4).budget.isEmpty)
    }

    // MARK: - Currency

    func testCurrencyConversionRoundTrip() {
        XCTAssertEqual(Currency.usd.amount(fromUSD: 100), 100, accuracy: 0.0001)
        XCTAssertEqual(Currency.sgd.amount(fromUSD: 100), 135, accuracy: 0.0001)
        XCTAssertEqual(Currency.sgd.usd(fromAmount: 135), 100, accuracy: 0.0001)
    }

    func testCurrencyFormatting() {
        XCTAssertTrue(Currency.usd.format(usd: 5000).hasPrefix("US$"))
        XCTAssertTrue(Currency.sgd.format(usd: 5000).hasPrefix("S$"))
        // Whole numbers render without decimals.
        XCTAssertFalse(Currency.usd.format(usd: 5000).contains("."))
    }

    // MARK: - Destination photos

    func testPhotoClassificationAndOrder() {
        let d = makeDestination(id: "x", image: "photo-x",
                                gallery: ["photo-y", "https://example.com/z.jpg", "  "])
        let refs = d.photos
        // Primary asset first, empty entries skipped, http treated as remote.
        XCTAssertEqual(refs.count, 3)
        XCTAssertEqual(refs[0], .asset("photo-x"))
        XCTAssertEqual(refs[1], .asset("photo-y"))
        XCTAssertEqual(refs[2], .remote(URL(string: "https://example.com/z.jpg")!))
    }

    // MARK: - Weather codes

    func testWeatherPresentationMapping() {
        XCTAssertEqual(DestinationWeather.presentation(for: 0).label, "Clear")
        XCTAssertEqual(DestinationWeather.presentation(for: 3).label, "Overcast")
        XCTAssertEqual(DestinationWeather.presentation(for: 61).symbol, "cloud.rain.fill")
        XCTAssertEqual(DestinationWeather.presentation(for: 95).label, "Thunderstorm")
        XCTAssertEqual(DestinationWeather.presentation(for: 9999).label, "—")   // unknown
    }
}
