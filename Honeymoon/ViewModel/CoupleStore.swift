//
//  CoupleStore.swift
//  Honeymoon
//
//  P4: manages the couple link and shared likes. Observes the signed-in user's
//  coupleId, the couple document, and the shared likes collection; computes
//  matches (destinations both partners liked) and flags a new match so the UI
//  can celebrate it.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class CoupleStore: ObservableObject {

    @Published private(set) var couple: Couple?
    @Published private(set) var matches: [CoupleMatch] = []
    @Published private(set) var isWorking = false
    /// Set when a brand-new match appears; the UI shows a celebration and clears it.
    @Published var pendingMatch: CoupleMatch?
    @Published var errorMessage: String?

    private var uid: String?
    private var coupleId: String?

    private var authHandle: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?
    private var coupleListener: ListenerRegistration?
    private var likesListener: ListenerRegistration?

    private var lastLikeDocs: [QueryDocumentSnapshot] = []
    private var knownMatchIDs: Set<String> = []
    private var didLoadMatches = false

    /// Linked = couple exists with both partners present.
    var isLinked: Bool { (couple?.members.count ?? 0) >= 2 }
    /// A couple was created but the partner hasn't joined yet.
    var isAwaitingPartner: Bool { (couple?.members.count ?? 0) == 1 }
    var inviteCode: String? { couple?.inviteCode }

    init() {
        guard FirebaseApp.app() != nil else { return }
        configure(uid: Auth.auth().currentUser?.uid)
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in self?.configure(uid: user?.uid) }
        }
    }

    deinit {
        userListener?.remove()
        coupleListener?.remove()
        likesListener?.remove()
        if let authHandle { Auth.auth().removeStateDidChangeListener(authHandle) }
    }

    private var db: Firestore { Firestore.firestore() }

    // MARK: - Lifecycle

    private func configure(uid newUID: String?) {
        guard newUID != uid else { return }
        uid = newUID
        userListener?.remove()
        attachCouple(nil)

        guard let newUID else { return }
        userListener = db.collection("users").document(newUID)
            .addSnapshotListener { [weak self] snapshot, _ in
                let cid = snapshot?.data()?["coupleId"] as? String
                Task { @MainActor in self?.attachCouple(cid) }
            }
    }

    private func attachCouple(_ newCoupleID: String?) {
        guard newCoupleID != coupleId else { return }
        coupleId = newCoupleID

        coupleListener?.remove()
        likesListener?.remove()
        couple = nil
        matches = []
        lastLikeDocs = []
        knownMatchIDs = []
        didLoadMatches = false

        guard let newCoupleID else { return }

        coupleListener = db.collection("couples").document(newCoupleID)
            .addSnapshotListener { [weak self] snapshot, _ in
                let couple = try? snapshot?.data(as: Couple.self)
                Task { @MainActor in
                    self?.couple = couple
                    self?.recomputeMatches()
                }
            }

        likesListener = db.collection("couples").document(newCoupleID).collection("likes")
            .addSnapshotListener { [weak self] snapshot, _ in
                let docs = snapshot?.documents ?? []
                Task { @MainActor in
                    self?.lastLikeDocs = docs
                    self?.recomputeMatches()
                }
            }
    }

    private func recomputeMatches() {
        guard let members = couple?.members, members.count == 2 else {
            matches = []
            return
        }
        let computed: [CoupleMatch] = lastLikeDocs.compactMap { doc in
            let data = doc.data()
            let likedBy = data["likedBy"] as? [String] ?? []
            guard members.allSatisfy(likedBy.contains) else { return nil }
            return CoupleMatch(
                id: doc.documentID,
                place: data["place"] as? String ?? "",
                country: data["country"] as? String ?? "",
                image: data["image"] as? String ?? ""
            )
        }

        let ids = Set(computed.map(\.id))
        if didLoadMatches {
            let added = ids.subtracting(knownMatchIDs)
            if let firstNew = computed.first(where: { added.contains($0.id) }) {
                pendingMatch = firstNew
            }
        }
        knownMatchIDs = ids
        didLoadMatches = true
        matches = computed.sorted { $0.place < $1.place }
    }

    // MARK: - Actions

    func createCouple() async {
        guard let uid else { return }
        isWorking = true
        defer { isWorking = false }
        let code = Self.generateCode()
        let coupleRef = db.collection("couples").document()
        do {
            try await coupleRef.setData([
                "members": [uid],
                "inviteCode": code,
                "createdAt": FieldValue.serverTimestamp()
            ])
            try await db.collection("invites").document(code).setData([
                "coupleId": coupleRef.documentID,
                "createdBy": uid,
                "createdAt": FieldValue.serverTimestamp()
            ])
            try await db.collection("users").document(uid).setData(["coupleId": coupleRef.documentID], merge: true)
        } catch {
            errorMessage = "Couldn't create an invite. Please try again."
        }
    }

    func joinCouple(code rawCode: String) async {
        guard let uid else { return }
        let code = rawCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !code.isEmpty else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            let invite = try await db.collection("invites").document(code).getDocument()
            guard invite.exists, let cid = invite.data()?["coupleId"] as? String else {
                errorMessage = "That code didn't match an invite."
                return
            }
            try await db.collection("couples").document(cid)
                .updateData(["members": FieldValue.arrayUnion([uid])])
            try await db.collection("users").document(uid).setData(["coupleId": cid], merge: true)
            // Single-use: retire the code once it's been redeemed.
            try? await db.collection("invites").document(code).delete()
        } catch {
            errorMessage = "Couldn't join. Check the code and try again."
        }
    }

    func leaveCouple() async {
        guard let uid, let coupleId else { return }
        isWorking = true
        defer { isWorking = false }
        // Retire any still-pending invite so a stale code can't be redeemed later.
        if let code = couple?.inviteCode {
            try? await db.collection("invites").document(code).delete()
        }
        try? await db.collection("couples").document(coupleId)
            .updateData(["members": FieldValue.arrayRemove([uid])])
        try? await db.collection("users").document(uid)
            .updateData(["coupleId": FieldValue.delete()])
    }

    /// Records a right-swipe into the couple's shared likes. No-op when solo.
    func recordLike(_ destination: Destination) {
        guard let uid, let coupleId else { return }
        db.collection("couples").document(coupleId).collection("likes").document(destination.id)
            .setData([
                "likedBy": FieldValue.arrayUnion([uid]),
                "place": destination.place,
                "country": destination.country,
                "image": destination.image,
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)
    }

    // MARK: - Helpers

    /// 8-character code from an unambiguous alphabet (no 0/O/1/I). Longer than a
    /// human-friendly 6 to make active codes impractical to guess.
    private static func generateCode() -> String {
        let alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<8).map { _ in alphabet.randomElement()! })
    }
}
