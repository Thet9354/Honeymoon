//
//  DestinationRepository.swift
//  Honeymoon
//

import Foundation
import FirebaseCore
import FirebaseFirestore

protocol DestinationRepository {
    func fetchAll() async throws -> [Destination]
}

struct InMemoryDestinationRepository: DestinationRepository {
    let destinations: [Destination]

    init(destinations: [Destination] = honeymoonData) {
        self.destinations = destinations
    }

    func fetchAll() async throws -> [Destination] {
        destinations
    }
}

/// Reads the `destinations` collection from Firestore. Returns an empty array
/// if the collection has not been seeded yet — `DestinationStore` treats empty
/// as "fall back to the bundled catalog".
struct FirestoreDestinationRepository: DestinationRepository {
    func fetchAll() async throws -> [Destination] {
        guard FirebaseApp.app() != nil else { return [] }
        let snapshot = try await Firestore.firestore().collection("destinations").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Destination.self) }
    }
}

@MainActor
final class DestinationStore: ObservableObject {

    @Published private(set) var destinations: [Destination] = []
    @Published private(set) var isLoading: Bool = false
    @Published var loadError: Error?

    private let repository: DestinationRepository

    init(repository: DestinationRepository = InMemoryDestinationRepository()) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await repository.fetchAll()
            // Empty means Firestore hasn't been seeded yet — use the bundled
            // catalog so the deck is never empty.
            destinations = fetched.isEmpty ? honeymoonData : fetched
        } catch {
            loadError = error
            // Offline or permission error: fall back to the bundled catalog
            // rather than showing an empty deck.
            if destinations.isEmpty { destinations = honeymoonData }
        }
    }
}
