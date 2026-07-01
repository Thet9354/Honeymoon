//
//  TravelPreferences.swift
//  Honeymoon
//
//  P2: the user's stated taste, captured by the onboarding quiz and editable
//  in Settings. Used to rank the swipe deck so the most relevant destinations
//  surface first. Stored locally (see PreferenceStore) since the quiz runs
//  before sign-in.
//

import Foundation

/// What the couple is planning. Tailors the AI itinerary's length, tone and copy
/// so the same destinations serve a lavish honeymoon and a quick romantic getaway
/// alike — the app is for couples' trips, not just honeymoons.
enum TripOccasion: String, Codable, CaseIterable, Identifiable {
    case honeymoon, anniversary, getaway, babymoon

    var id: String { rawValue }

    var label: String {
        switch self {
        case .honeymoon:   "Honeymoon"
        case .anniversary: "Anniversary"
        case .getaway:     "Romantic getaway"
        case .babymoon:    "Babymoon"
        }
    }

    var subtitle: String {
        switch self {
        case .honeymoon:   "The big one — celebrate your marriage"
        case .anniversary: "Mark another year together"
        case .getaway:     "A quick escape, just the two of you"
        case .babymoon:    "Relax before the baby arrives"
        }
    }

    var systemImage: String {
        switch self {
        case .honeymoon:   "heart.fill"
        case .anniversary: "gift.fill"
        case .getaway:     "airplane.departure"
        case .babymoon:    "stroller.fill"
        }
    }

    /// Default trip length the AI plans for, in days.
    var defaultTripDays: Int {
        switch self {
        case .honeymoon:   7
        case .anniversary: 5
        case .getaway:     3
        case .babymoon:    6
        }
    }

    /// Short noun phrase describing the trip, fed to the AI planner.
    var planDescriptor: String {
        switch self {
        case .honeymoon:   "a once-in-a-lifetime honeymoon"
        case .anniversary: "a romantic anniversary trip"
        case .getaway:     "a short romantic getaway (a \"mini-moon\")"
        case .babymoon:    "a relaxed pre-baby babymoon"
        }
    }

    /// Tone/pacing guidance for the AI planner.
    var toneGuidance: String {
        switch self {
        case .honeymoon:   "Lean into once-in-a-lifetime romance and special splurges; pace it indulgently."
        case .anniversary: "Celebratory and sentimental; weave in a standout dinner or experience to mark the milestone."
        case .getaway:     "Keep it relaxed and efficient for a short break — fewer, higher-impact moments and minimal logistics."
        case .babymoon:    "Calm, comfortable and low-exertion; prioritise rest, gentle activities and easy access to amenities."
        }
    }

    /// User-facing word for the generated plan, e.g. "honeymoon itinerary".
    var itineraryNoun: String {
        switch self {
        case .honeymoon:   "honeymoon itinerary"
        case .anniversary: "anniversary itinerary"
        case .getaway:     "getaway plan"
        case .babymoon:    "babymoon plan"
        }
    }
}

/// A coarse budget band for two people, mapped to the destination budget field.
enum BudgetBand: String, Codable, CaseIterable, Identifiable {
    case budget, mid, luxury

    var id: String { rawValue }

    var label: String {
        switch self {
        case .budget: "Budget-friendly"
        case .mid:    "Mid-range"
        case .luxury: "Luxury"
        }
    }

    var detail: String {
        switch self {
        case .budget: "Under $3,500"
        case .mid:    "$3,500 – $5,000"
        case .luxury: "$5,000+"
        }
    }

    func contains(_ budgetUSD: Int) -> Bool {
        switch self {
        case .budget: budgetUSD > 0 && budgetUSD < 3500
        case .mid:    budgetUSD >= 3500 && budgetUSD < 5000
        case .luxury: budgetUSD >= 5000
        }
    }
}

/// A high-level interest the user can pick. Each maps to one or more of the
/// destination `tags` used for scoring.
enum Interest: String, Codable, CaseIterable, Identifiable {
    case beaches, citiesCulture, adventure, romance, foodShopping, luxury

    var id: String { rawValue }

    var label: String {
        switch self {
        case .beaches:      "Beaches & islands"
        case .citiesCulture: "Cities & culture"
        case .adventure:    "Adventure & nature"
        case .romance:      "Romance & relaxation"
        case .foodShopping: "Food & shopping"
        case .luxury:       "Luxury escapes"
        }
    }

    var systemImage: String {
        switch self {
        case .beaches:      "beach.umbrella"
        case .citiesCulture: "building.2"
        case .adventure:    "mountain.2"
        case .romance:      "heart"
        case .foodShopping: "fork.knife"
        case .luxury:       "sparkles"
        }
    }

    /// Destination tags this interest matches against.
    var tags: Set<String> {
        switch self {
        case .beaches:      ["beach", "tropical"]
        case .citiesCulture: ["city", "culture", "history"]
        case .adventure:    ["adventure", "nature", "mountains", "outdoors", "scenic"]
        case .romance:      ["romantic", "relaxation"]
        case .foodShopping: ["food", "shopping"]
        case .luxury:       ["luxury", "desert"]
        }
    }
}

struct TravelPreferences: Codable, Equatable {
    /// What the couple is planning. Drives occasion-aware copy and AI tailoring;
    /// optional so pre-pivot saved preferences still decode (treated as a generic
    /// romantic trip until the couple picks one).
    var occasion: TripOccasion? = nil
    var interests: Set<Interest> = []
    var budgetBand: BudgetBand? = nil
    var regions: Set<String> = []

    /// All regions a user can prefer (matches the `region` values in the catalog).
    static let allRegions = ["Asia", "Europe", "North America", "Middle East", "South America", "Oceania"]

    var isEmpty: Bool { interests.isEmpty && budgetBand == nil && regions.isEmpty }

    /// Union of all destination tags implied by the chosen interests.
    var preferredTags: Set<String> {
        interests.reduce(into: Set<String>()) { $0.formUnion($1.tags) }
    }
}

extension TravelPreferences {
    /// Relevance score for a destination. Higher is a better match.
    func score(for destination: Destination) -> Int {
        var score = 0
        let prefTags = preferredTags
        if !prefTags.isEmpty {
            score += destination.tags.filter { prefTags.contains($0) }.count * 2
        }
        if regions.contains(destination.region) {
            score += 3
        }
        if let budgetBand, budgetBand.contains(destination.estBudgetForTwoUSD) {
            score += 2
        }
        return score
    }

    /// A short, human-readable reason this destination suits the couple, for the
    /// top card ("Picked for you · beaches & islands · Asia"). Returns nil when no
    /// preferences are set or nothing matches, so the card stays clean.
    func rationale(for destination: Destination) -> String? {
        guard !isEmpty else { return nil }
        var reasons: [String] = []
        let destinationTags = Set(destination.tags)
        if let matched = interests.first(where: { !$0.tags.isDisjoint(with: destinationTags) }) {
            reasons.append(matched.label.lowercased())
        }
        if !destination.region.isEmpty, regions.contains(destination.region) {
            reasons.append(destination.region)
        }
        if let budgetBand, budgetBand.contains(destination.estBudgetForTwoUSD) {
            reasons.append(budgetBand.label.lowercased())
        }
        guard !reasons.isEmpty else { return nil }
        return "Picked for you · " + reasons.prefix(2).joined(separator: " · ")
    }

    /// Returns destinations ranked by relevance. Ties and the no-preference
    /// case preserve the original order (stable sort by index).
    func ranked(_ destinations: [Destination]) -> [Destination] {
        guard !isEmpty else { return destinations }
        return destinations
            .enumerated()
            .sorted { lhs, rhs in
                let ls = score(for: lhs.element), rs = score(for: rhs.element)
                return ls == rs ? lhs.offset < rhs.offset : ls > rs
            }
            .map(\.element)
    }
}
