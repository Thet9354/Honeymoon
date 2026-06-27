//
//  Itinerary.swift
//  Honeymoon
//
//  P5: the Premium payoff. A plausible day-by-day honeymoon itinerary plus a
//  budget breakdown, generated deterministically from a destination's editorial
//  fields (highlights, season, budget). No per-destination authoring required,
//  so it works for the bundled catalogue and any future Firestore destinations.
//

import Foundation

struct ItineraryDay: Identifiable {
    let id: Int            // day number, also the stable identity
    let title: String
    let morning: String
    let afternoon: String
    let evening: String
    let dining: String

    var dayNumber: Int { id }
}

struct Itinerary {
    let destination: Destination
    let days: [ItineraryDay]
    let budget: [BudgetLine]

    struct BudgetLine: Identifiable {
        let id = UUID()
        let category: String
        let amountUSD: Int

        var display: String {
            guard amountUSD > 0 else { return "—" }
            return Currency.current.format(usd: Double(amountUSD))
        }
    }

    var budgetTotalDisplay: String {
        let total = budget.reduce(0) { $0 + $1.amountUSD }
        guard total > 0 else { return destination.budgetDisplay }
        return Currency.current.format(usd: Double(total))
    }
}

extension Itinerary {

    /// Builds a `dayCount`-day itinerary for a destination. Deterministic: the
    /// same destination always yields the same plan.
    static func generate(for destination: Destination, days dayCount: Int = 7) -> Itinerary {
        let place = destination.place
        // Seed activities from the destination's highlights; fall back to
        // generic-but-pleasant beats when a destination has few.
        let highlights = destination.highlights.isEmpty
            ? ["the old town", "the coastline", "a local market", "the viewpoints", "the hidden cafés"]
            : destination.highlights

        var days: [ItineraryDay] = []
        for day in 1...max(dayCount, 1) {
            days.append(buildDay(day, of: dayCount, place: place, highlights: highlights))
        }

        return Itinerary(destination: destination, days: days, budget: budgetLines(for: destination))
    }

    private static func buildDay(_ day: Int, of total: Int, place: String, highlights: [String]) -> ItineraryDay {
        // Pick a focus highlight for the day, cycling through the list.
        let focus = highlights[(day - 1) % highlights.count]
        let nextFocus = highlights[day % highlights.count]

        switch day {
        case 1:
            return ItineraryDay(
                id: day,
                title: "Arrival & first evening",
                morning: "Land in \(place), transfer to your stay and settle in.",
                afternoon: "Unpack and take a slow first walk nearby to find your bearings.",
                evening: "Toast to the trip with a relaxed welcome dinner close to your hotel.",
                dining: "A romantic spot near your stay — keep it easy after travel."
            )
        case total:
            return ItineraryDay(
                id: day,
                title: "Farewell to \(place)",
                morning: "A final unhurried breakfast and last looks at \(focus).",
                afternoon: "Pick up a keepsake or two, then ready your bags.",
                evening: "Head to the airport carrying the best of \(place) with you.",
                dining: "A light, memorable lunch before you go."
            )
        default:
            return ItineraryDay(
                id: day,
                title: "Day \(day): \(focus.capitalizedFirst)",
                morning: "Start with \(focus) while it's quiet and the light is soft.",
                afternoon: "Slow down together — wander, swim or simply linger.",
                evening: "Sunset moment, then drift toward \(nextFocus) for tomorrow.",
                dining: "Book somewhere special tonight — this is a celebration."
            )
        }
    }

    /// Splits the destination's all-in estimate across typical categories.
    private static func budgetLines(for destination: Destination) -> [BudgetLine] {
        let total = destination.estBudgetForTwoUSD
        guard total > 0 else { return [] }
        func share(_ pct: Double) -> Int { Int((Double(total) * pct).rounded()) }
        return [
            BudgetLine(category: "Flights",     amountUSD: share(0.35)),
            BudgetLine(category: "Stays",       amountUSD: share(0.30)),
            BudgetLine(category: "Dining",      amountUSD: share(0.15)),
            BudgetLine(category: "Experiences", amountUSD: share(0.12)),
            BudgetLine(category: "Everything else", amountUSD: share(0.08))
        ]
    }
}

private extension String {
    /// Capitalizes only the first character, leaving the rest as written.
    var capitalizedFirst: String {
        guard let first else { return self }
        return first.uppercased() + String(dropFirst())
    }
}

// MARK: - Generated payload (Cloud Function / Firestore cache)

/// The Codable payload returned by the `generateItinerary` Cloud Function and
/// cached in Firestore. It mirrors the function's JSON schema exactly. Days carry
/// no stable id in transit — it's assigned from order when converting to the
/// runtime `Itinerary`.
struct GeneratedItinerary: Codable {
    struct Day: Codable {
        let title: String
        let morning: String
        let afternoon: String
        let evening: String
        let dining: String
    }
    struct BudgetLineDTO: Codable {
        let category: String
        let amountUSD: Int
    }
    var days: [Day]
    var budget: [BudgetLineDTO]
}

extension Itinerary {
    /// Builds a runtime `Itinerary` for a destination from a generated payload.
    init(destination: Destination, generated: GeneratedItinerary) {
        self.destination = destination
        self.days = generated.days.enumerated().map { index, day in
            ItineraryDay(
                id: index + 1,
                title: day.title,
                morning: day.morning,
                afternoon: day.afternoon,
                evening: day.evening,
                dining: day.dining
            )
        }
        self.budget = generated.budget.map { BudgetLine(category: $0.category, amountUSD: $0.amountUSD) }
    }
}
