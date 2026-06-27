//
//  PurchaseStore.swift
//  Honeymoon
//
//  P5: in-app purchase via StoreKit 2. Loads the Premium products, runs the
//  purchase, restores, listens for transaction updates, and exposes a single
//  `isPremium` entitlement the rest of the app gates on. No third-party SDK.
//
//  Premium unlocks the full day-by-day itineraries and advanced planning; the
//  swipe deck and Couple Mode stay free (couple linking drives growth, so it is
//  never gated).
//

import Foundation
import StoreKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class PurchaseStore: ObservableObject {

    /// The two products sold. IDs must match App Store Connect and the local
    /// `Honeymoon.storekit` configuration used for simulator testing.
    enum PremiumProduct: String, CaseIterable {
        case lifetime = "com.thetpine.honeymoon.premium.lifetime"
        case annual   = "com.thetpine.honeymoon.premium.annual"
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPremium = false
    @Published private(set) var isLoadingProducts = false
    @Published var purchaseError: String?

    private var updatesTask: Task<Void, Never>?
    private var authHandle: AuthStateDidChangeListenerHandle?

    /// Hero offer: one-time unlock, a natural fit for a once-in-a-lifetime trip.
    var lifetimeProduct: Product? { products.first { $0.id == PremiumProduct.lifetime.rawValue } }
    /// Alternative: annual subscription (carries the free-trial intro offer).
    var annualProduct: Product? { products.first { $0.id == PremiumProduct.annual.rawValue } }

    init() {
        updatesTask = listenForTransactions()
        // Re-mirror the entitlement once a user signs in, so a returning premium
        // user reliably passes the server-side gate even if auth restores after
        // the initial entitlement check.
        if FirebaseApp.app() != nil {
            authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
                guard let self, user != nil else { return }
                Task { @MainActor in self.mirrorEntitlement(self.isPremium) }
            }
        }
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
        if let authHandle { Auth.auth().removeStateDidChangeListener(authHandle) }
    }

    // MARK: - Loading

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let ids = PremiumProduct.allCases.map(\.rawValue)
            let loaded = try await Product.products(for: ids)
            // Lifetime first, then annual.
            products = loaded.sorted { sortIndex($0.id) < sortIndex($1.id) }
        } catch {
            purchaseError = "Couldn't load purchase options. Please check your connection and try again."
        }
    }

    private func sortIndex(_ id: String) -> Int {
        id == PremiumProduct.lifetime.rawValue ? 0 : 1
    }

    // MARK: - Buying

    /// Returns true when the purchase succeeded and Premium is now active.
    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await refreshEntitlements()
                await transaction.finish()
                return isPremium
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseError = "The purchase couldn't be completed. You were not charged."
            return false
        }
    }

    /// Restores past purchases (e.g. a Lifetime unlock on a new device).
    func restore() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if !isPremium {
                purchaseError = "No previous purchase was found for this Apple ID."
            }
        } catch {
            purchaseError = "Couldn't restore purchases. Please try again."
        }
    }

    // MARK: - Entitlements

    /// Recomputes `isPremium` from the user's current entitlements. Premium is
    /// active if either product is owned and not revoked.
    func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if PremiumProduct(rawValue: transaction.productID) != nil,
               transaction.revocationDate == nil {
                active = true
            }
        }
        isPremium = active
        mirrorEntitlement(active)
    }

    /// Mirrors the entitlement into Firestore (`users/{uid}.isPremium`) so the
    /// itinerary Cloud Function can gate generation server-side.
    private func mirrorEntitlement(_ premium: Bool) {
        guard FirebaseApp.app() != nil, let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid)
            .setData(["isPremium": premium], merge: true)
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                if let transaction = try? self.checkVerified(result) {
                    await self.refreshEntitlements()
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let safe): return safe
        }
    }
}
