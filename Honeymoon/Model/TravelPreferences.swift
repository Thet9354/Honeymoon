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
