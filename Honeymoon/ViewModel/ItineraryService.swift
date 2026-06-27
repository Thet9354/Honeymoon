//
//  ItineraryService.swift
//  Honeymoon
//
//  Stage A: fetches a personalized honeymoon itinerary. Cache-first (Firestore),
//  then the `generateItinerary` Cloud Function (which calls Claude securely), then
//  a deterministic local fallback so the screen never fails. The expensive Claude
//  call only fires for a premium user on a cache miss, and the function enforces a
//  hard per-user monthly cap as a cost backstop.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

@MainActor
final class ItineraryService: ObservableObject {

    private let functions = Functions.functions()

    /// Returns an itinerary for a destination. `forceRegenerate` bypasses the
    /// cache (used by the "Regenerate" action).
    func itinerary(
        for destination: Destination,
        preferences: TravelPreferences,
        startDate: Date? = nil,
        forceRegenerate: Bool = false
    ) async -> Itinerary {
        let signature = Self.signature(preferences: preferences, startDate: startDate)

        if !forceRegenerate,
           let cached = await loadCached(destinationId: destination.id, signature: signature) {
            return Itinerary(destination: destination, generated: cached)
        }

        do {
            let generated = try await callFunction(
                destination: destination, preferences: preferences, startDate: startDate
            )
            await saveCached(destinationId: destination.id, signature: signature, generated: generated)
            return Itinerary(destination: destination, generated: generated)
        } catch {
            // Offline, function error, cap reached, or not premium → never fail the
            // screen; serve the deterministic plan instead.
            return Itinerary.generate(for: destination)
        }
    }

    // MARK: - Cache (users/{uid}/itineraries/{destinationId})

    private func cacheDoc(_ destinationId: String) -> DocumentReference? {
        guard FirebaseApp.app() != nil, let uid = Auth.auth().currentUser?.uid else { return nil }
        return Firestore.firestore()
            .collection("users").document(uid)
            .collection("itineraries").document(destinationId)
    }

    private func loadCached(destinationId: String, signature: String) async -> GeneratedItinerary? {
        guard let doc = cacheDoc(destinationId) else { return nil }
        guard let snapshot = try? await doc.getDocument(),
              snapshot.exists,
              let cached = try? snapshot.data(as: CachedItinerary.self),
              cached.signature == signature else { return nil }
        return GeneratedItinerary(days: cached.days, budget: cached.budget)
    }

    private func saveCached(destinationId: String, signature: String, generated: GeneratedItinerary) async {
        guard let doc = cacheDoc(destinationId) else { return }
        let cached = CachedItinerary(days: generated.days, budget: generated.budget, signature: signature)
        try? doc.setData(from: cached, merge: false)
    }

    // MARK: - Cloud Function

    private func callFunction(
        destination: Destination,
        preferences: TravelPreferences,
        startDate: Date?
    ) async throws -> GeneratedItinerary {
        var payload: [String: Any] = [
            "destination": [
                "place": destination.place,
                "country": destination.country,
                "summary": destination.summary,
                "region": destination.region,
                "bestSeason": destination.bestSeason,
                "highlights": destination.highlights,
                "estBudgetForTwoUSD": destination.estBudgetForTwoUSD
            ],
            "preferences": Self.preferencesPayload(preferences),
            "days": 7
        ]
        if let startDate { payload["startDate"] = Self.dateFormatter.string(from: startDate) }

        let result = try await functions.httpsCallable("generateItinerary").call(payload)
        let json = try JSONSerialization.data(withJSONObject: result.data)
        return try JSONDecoder().decode(GeneratedItinerary.self, from: json)
    }

    // MARK: - Helpers

    private static func preferencesPayload(_ prefs: TravelPreferences) -> [String: Any] {
        var dict: [String: Any] = [:]
        if !prefs.interests.isEmpty { dict["interests"] = prefs.interests.map(\.label) }
        if let band = prefs.budgetBand { dict["budgetBand"] = "\(band.label) (\(band.detail))" }
        if !prefs.regions.isEmpty { dict["regions"] = Array(prefs.regions) }
        return dict
    }

    /// Stable signature of the inputs that affect generation. A cache entry is
    /// reused only when this matches, so changing preferences/date regenerates.
    private static func signature(preferences: TravelPreferences, startDate: Date?) -> String {
        let interests = preferences.interests.map(\.rawValue).sorted().joined(separator: ",")
        let regions = preferences.regions.sorted().joined(separator: ",")
        let band = preferences.budgetBand?.rawValue ?? "-"
        let date = startDate.map { dateFormatter.string(from: $0) } ?? "-"
        return "v1|\(interests)|\(regions)|\(band)|\(date)"
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}

/// The Firestore cache document: the generated content plus the signature of the
/// inputs that produced it.
private struct CachedItinerary: Codable {
    var days: [GeneratedItinerary.Day]
    var budget: [GeneratedItinerary.BudgetLineDTO]
    var signature: String
}
