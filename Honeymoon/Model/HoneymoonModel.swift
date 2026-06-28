//
//  HoneymoonModel.swift
//  Honeymoon
//
//  Created by Phoon Thet Pine on 31/10/23.
//

import Foundation

struct Destination: Identifiable, Codable, Hashable {
    var id: String
    var place: String
    var country: String
    var image: String

    // MARK: - P1 enrichment
    // These power the detail screen. They are decoded defensively so a Firestore
    // document that predates a field (or omits it) still decodes cleanly.

    /// Short evocative description shown at the top of the detail page.
    var summary: String
    /// Broad region used for filtering/personalization (e.g. "Asia", "Europe").
    var region: String
    /// Free-form tags for personalization and matching (e.g. "beach", "luxury").
    var tags: [String]
    /// Indicative best months to visit, pre-formatted for display (e.g. "Nov–Apr").
    var bestSeason: String
    /// Rough all-in estimate for two people, in USD. Indicative only.
    var estBudgetForTwoUSD: Int
    /// Indicative long-haul flight time in hours. Indicative only.
    var flightHours: Int
    /// Editorial rating out of 5.
    var rating: Double
    /// Short romantic highlights shown as chips on the detail page.
    var highlights: [String]
    /// Extra photos for the detail-screen gallery, shown after the bundled `image`.
    /// Each entry is either a bundled asset name or a remote `https` URL (entries
    /// starting with "http" are treated as URLs). Empty = single-photo hero.
    var gallery: [String]
    /// Map coordinate. Stored so the detail map is instant and reliable instead of
    /// depending on the rate-limited runtime geocoder. `nil` falls back to geocoding.
    var latitude: Double?
    var longitude: Double?

    init(
        id: String,
        place: String,
        country: String,
        image: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        summary: String = "",
        region: String = "",
        tags: [String] = [],
        bestSeason: String = "",
        estBudgetForTwoUSD: Int = 0,
        flightHours: Int = 0,
        rating: Double = 0,
        highlights: [String] = [],
        gallery: [String] = []
    ) {
        self.id = id
        self.place = place
        self.country = country
        self.image = image
        self.summary = summary
        self.region = region
        self.tags = tags
        self.bestSeason = bestSeason
        self.estBudgetForTwoUSD = estBudgetForTwoUSD
        self.flightHours = flightHours
        self.rating = rating
        self.highlights = highlights
        self.gallery = gallery
        self.latitude = latitude
        self.longitude = longitude
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        place = try c.decode(String.self, forKey: .place)
        country = try c.decode(String.self, forKey: .country)
        image = try c.decode(String.self, forKey: .image)
        summary = try c.decodeIfPresent(String.self, forKey: .summary) ?? ""
        region = try c.decodeIfPresent(String.self, forKey: .region) ?? ""
        tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
        bestSeason = try c.decodeIfPresent(String.self, forKey: .bestSeason) ?? ""
        estBudgetForTwoUSD = try c.decodeIfPresent(Int.self, forKey: .estBudgetForTwoUSD) ?? 0
        flightHours = try c.decodeIfPresent(Int.self, forKey: .flightHours) ?? 0
        rating = try c.decodeIfPresent(Double.self, forKey: .rating) ?? 0
        highlights = try c.decodeIfPresent([String].self, forKey: .highlights) ?? []
        gallery = try c.decodeIfPresent([String].self, forKey: .gallery) ?? []
        latitude = try c.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try c.decodeIfPresent(Double.self, forKey: .longitude)
    }
}

extension Destination {
    /// A single resolved photo — either a bundled asset name or a remote URL.
    enum PhotoRef: Hashable, Identifiable {
        case asset(String)
        case remote(URL)

        var id: String {
            switch self {
            case .asset(let name): "asset:\(name)"
            case .remote(let url): "remote:\(url.absoluteString)"
            }
        }
    }

    /// Ordered photos for the detail gallery: the bundled hero `image` first,
    /// then each `gallery` entry classified as a bundled asset or a remote URL.
    var photos: [PhotoRef] {
        var refs: [PhotoRef] = image.isEmpty ? [] : [.asset(image)]
        for entry in gallery {
            let trimmed = entry.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            if trimmed.hasPrefix("http"), let url = URL(string: trimmed) {
                refs.append(.remote(url))
            } else {
                refs.append(.asset(trimmed))
            }
        }
        return refs
    }
}

extension Destination {
    /// Budget formatted as a compact currency string in the user's chosen
    /// currency, e.g. "S$9,180". The stored value is a USD base.
    var budgetDisplay: String {
        guard estBudgetForTwoUSD > 0 else { return "—" }
        return Currency.current.format(usd: Double(estBudgetForTwoUSD))
    }

    /// Flight time formatted for display, e.g. "17h".
    var flightDisplay: String {
        flightHours > 0 ? "\(flightHours)h" : "—"
    }
}
