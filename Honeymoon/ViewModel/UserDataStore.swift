//
//  UserDataStore.swift
//  Honeymoon
//
//  Per-user persistence of favorites and bookings in Firestore, under
//  users/{uid}/favorites and users/{uid}/bookings. Real-time via snapshot
//  listeners; attaches/detaches automatically as the auth state changes.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

struct FavoriteItem: Identifiable, Hashable {
    let id: String          // destination id
    let place: String
    let country: String
    let image: String
    let savedAt: Date?
}

struct BookingItem: Identifiable, Hashable {
    let id: String          // destination id
    let place: String
    let country: String
    let image: String
    let bookedAt: Date?
}

@MainActor
final class UserDataStore: ObservableObject {

    @Published private(set) var favorites: [FavoriteItem] = []
    @Published private(set) var bookings: [BookingItem] = []

    private var authHandle: AuthStateDidChangeListenerHandle?
    private var favoritesListener: ListenerRegistration?
    private var bookingsListener: ListenerRegistration?
    private var uid: String?

    init() {
        guard FirebaseApp.app() != nil else { return }
        configure(uid: Auth.auth().currentUser?.uid)
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in self?.configure(uid: user?.uid) }
        }
    }

    deinit {
        favoritesListener?.remove()
        bookingsListener?.remove()
        if let authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }

    func isFavorite(_ destination: Destination) -> Bool {
        favorites.contains { $0.id == destination.id }
    }

    // MARK: - Writes

    func addFavorite(_ destination: Destination) {
        guard let collection = favoritesCollection() else { return }
        collection.document(destination.id).setData([
            "place": destination.place,
            "country": destination.country,
            "image": destination.image,
            "savedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    func removeFavorite(_ id: String) {
        favoritesCollection()?.document(id).delete()
    }

    func addBooking(_ destination: Destination) {
        guard let uid else { return }
        Firestore.firestore()
            .collection("users").document(uid)
            .collection("bookings").document(destination.id)
            .setData([
                "place": destination.place,
                "country": destination.country,
                "image": destination.image,
                "bookedAt": FieldValue.serverTimestamp()
            ], merge: true)
    }

    func removeBooking(_ id: String) {
        guard let uid else { return }
        Firestore.firestore()
            .collection("users").document(uid)
            .collection("bookings").document(id)
            .delete()
    }

    // MARK: - Lifecycle

    private func configure(uid newUID: String?) {
        guard newUID != uid else { return }
        uid = newUID

        favoritesListener?.remove()
        bookingsListener?.remove()
        favoritesListener = nil
        bookingsListener = nil

        guard let newUID else {
            favorites = []
            bookings = []
            return
        }

        let base = Firestore.firestore().collection("users").document(newUID)

        favoritesListener = base.collection("favorites").addSnapshotListener { [weak self] snapshot, _ in
            let items = (snapshot?.documents ?? []).map { Self.favorite(from: $0) }
            Task { @MainActor in
                self?.favorites = items.sorted { ($0.savedAt ?? .distantFuture) > ($1.savedAt ?? .distantFuture) }
            }
        }

        bookingsListener = base.collection("bookings").addSnapshotListener { [weak self] snapshot, _ in
            let items = (snapshot?.documents ?? []).map { Self.booking(from: $0) }
            Task { @MainActor in
                self?.bookings = items.sorted { ($0.bookedAt ?? .distantFuture) > ($1.bookedAt ?? .distantFuture) }
            }
        }
    }

    private func favoritesCollection() -> CollectionReference? {
        guard let uid else { return nil }
        return Firestore.firestore().collection("users").document(uid).collection("favorites")
    }

    // MARK: - Mapping

    private static func favorite(from doc: QueryDocumentSnapshot) -> FavoriteItem {
        let data = doc.data()
        return FavoriteItem(
            id: doc.documentID,
            place: data["place"] as? String ?? "",
            country: data["country"] as? String ?? "",
            image: data["image"] as? String ?? "",
            savedAt: (data["savedAt"] as? Timestamp)?.dateValue()
        )
    }

    private static func booking(from doc: QueryDocumentSnapshot) -> BookingItem {
        let data = doc.data()
        return BookingItem(
            id: doc.documentID,
            place: data["place"] as? String ?? "",
            country: data["country"] as? String ?? "",
            image: data["image"] as? String ?? "",
            bookedAt: (data["bookedAt"] as? Timestamp)?.dateValue()
        )
    }
}
