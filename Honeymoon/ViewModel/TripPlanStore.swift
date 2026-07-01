//
//  TripPlanStore.swift
//  Honeymoon
//
//  Stage B: the trip plan is now SHARED and LIVE for linked couples. When the
//  user is in a couple it reads/writes couples/{coupleId}/trips/{destinationId};
//  otherwise it falls back to the per-user path so solo users still work.
//
//  Budget items and checklist items live in per-item subcollections (…/budget,
//  …/checklist) rather than arrays on the parent doc, so simultaneous edits by
//  both partners don't clobber each other. Travel date and free-form notes stay
//  on the parent doc. Everything streams via real-time snapshot listeners.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class TripPlanStore: ObservableObject {

    @Published var plan: TripPlan
    @Published private(set) var isLoading = false
    /// True when this plan is shared with a linked partner (couple-scoped).
    @Published private(set) var isShared = false

    private var notesSaveTask: Task<Void, Never>?
    /// The last notes value we wrote, so the listener can ignore our own echo and
    /// avoid clobbering in-progress local typing.
    private var lastWrittenNotes: String?

    private var parentRef: DocumentReference?
    private var parentListener: ListenerRegistration?
    private var budgetListener: ListenerRegistration?
    private var checklistListener: ListenerRegistration?
    private var didStart = false

    init(seed: TripPlan) {
        self.plan = seed
    }

    deinit {
        parentListener?.remove()
        budgetListener?.remove()
        checklistListener?.remove()
    }

    private var db: Firestore { Firestore.firestore() }

    // MARK: - Lifecycle

    /// Resolves the scope (shared vs per-user), migrates any legacy data once,
    /// then attaches live listeners. Safe to call repeatedly.
    func load() async {
        guard !didStart else { return }
        guard FirebaseApp.app() != nil, let uid = Auth.auth().currentUser?.uid else { return }
        didStart = true
        isLoading = true
        defer { isLoading = false }

        let userSnap = try? await db.collection("users").document(uid).getDocument()
        let coupleId = userSnap?.get("coupleId") as? String

        let ref: DocumentReference
        if let coupleId {
            ref = db.collection("couples").document(coupleId)
                .collection("trips").document(plan.destinationId)
            isShared = true
        } else {
            ref = db.collection("users").document(uid)
                .collection("trips").document(plan.destinationId)
            isShared = false
        }
        parentRef = ref

        await migrateIfNeeded(into: ref, uid: uid, coupleId: coupleId)

        // Ensure the parent doc exists with identity so the plan is discoverable.
        ref.setData([
            "destinationId": plan.destinationId,
            "place": plan.place,
            "country": plan.country,
            "image": plan.image
        ], merge: true) { _ in }

        attachListeners(ref)
    }

    // MARK: - Listeners

    private func attachListeners(_ ref: DocumentReference) {
        parentListener = ref.addSnapshotListener { [weak self] snapshot, _ in
            guard let data = snapshot?.data() else { return }
            Task { @MainActor in self?.applyParent(data) }
        }
        budgetListener = ref.collection("budget").addSnapshotListener { [weak self] snapshot, _ in
            let items = (snapshot?.documents ?? []).compactMap { try? $0.data(as: BudgetItem.self) }
            Task { @MainActor in self?.plan.budgetItems = items.sorted { $0.createdAt < $1.createdAt } }
        }
        checklistListener = ref.collection("checklist").addSnapshotListener { [weak self] snapshot, _ in
            let items = (snapshot?.documents ?? []).compactMap { try? $0.data(as: ChecklistItem.self) }
            Task { @MainActor in self?.plan.checklist = items.sorted { $0.createdAt < $1.createdAt } }
        }
    }

    private func applyParent(_ data: [String: Any]) {
        if let ts = data["startDate"] as? Timestamp {
            plan.startDate = ts.dateValue()
        } else if data["startDate"] == nil {
            plan.startDate = nil
        }
        // Apply remote notes, but never overwrite our own echo or fresher local text.
        if let notes = data["notes"] as? String, notes != plan.notes, notes != lastWrittenNotes {
            plan.notes = notes
        }
    }

    // MARK: - Structured edits (write to Firestore; the listener reflects them)

    func setStartDate(_ date: Date?) {
        plan.startDate = date
        guard let parentRef else { return }
        if let date {
            parentRef.setData(["startDate": date], merge: true)
        } else {
            parentRef.updateData(["startDate": FieldValue.delete()])
        }
    }

    func addBudgetItem(title: String, amount: Double) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let parentRef else { return }
        let item = BudgetItem(title: trimmed, amountUSD: amount)
        try? parentRef.collection("budget").document(item.id).setData(from: item)
    }

    func removeBudgetItems(at offsets: IndexSet) {
        guard let parentRef else { return }
        for index in offsets where plan.budgetItems.indices.contains(index) {
            parentRef.collection("budget").document(plan.budgetItems[index].id).delete()
        }
    }

    func addChecklistItem(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let parentRef else { return }
        let item = ChecklistItem(title: trimmed)
        try? parentRef.collection("checklist").document(item.id).setData(from: item)
    }

    func toggleChecklistItem(_ item: ChecklistItem) {
        guard let parentRef else { return }
        parentRef.collection("checklist").document(item.id).updateData(["done": !item.done])
    }

    func removeChecklistItems(at offsets: IndexSet) {
        guard let parentRef else { return }
        for index in offsets where plan.checklist.indices.contains(index) {
            parentRef.collection("checklist").document(plan.checklist[index].id).delete()
        }
    }

    // MARK: - Notes (debounced save)

    func notesChanged() {
        notesSaveTask?.cancel()
        notesSaveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 800_000_000)
            guard !Task.isCancelled, let self, let parentRef = self.parentRef else { return }
            self.lastWrittenNotes = self.plan.notes
            parentRef.setData(["notes": self.plan.notes], merge: true) { _ in }
        }
    }

    // MARK: - Bridge from a generated itinerary

    /// Seeds this trip from an AI itinerary: adds the budget breakdown (deduped by
    /// title) and writes the day-by-day plan into notes. Idempotent — running it
    /// twice won't duplicate budget lines or re-append the plan.
    func applyItinerary(_ itinerary: Itinerary) async {
        guard let parentRef else { return }

        // Budget: add only lines not already present (by title).
        let existing = (try? await parentRef.collection("budget").getDocuments())?
            .documents.compactMap { try? $0.data(as: BudgetItem.self) } ?? []
        let existingTitles = Set(existing.map(\.title))
        var order = Date().timeIntervalSince1970
        for line in itinerary.budget where line.amountUSD > 0 && !existingTitles.contains(line.category) {
            let item = BudgetItem(title: line.category, amountUSD: Double(line.amountUSD), createdAt: order)
            order += 1
            try? parentRef.collection("budget").document(item.id).setData(from: item) { _ in }
        }

        // Notes: write the plan once (don't clobber existing notes or re-append).
        let currentNotes = ((try? await parentRef.getDocument())?.data()?["notes"] as? String) ?? ""
        let planText = Self.notesText(from: itinerary)
        if currentNotes.isEmpty {
            writeNotes(planText)
        } else if !currentNotes.contains(Self.itineraryMarker) {
            writeNotes(currentNotes + "\n\n" + planText)
        }
    }

    private func writeNotes(_ text: String) {
        plan.notes = text
        lastWrittenNotes = text
        parentRef?.setData(["notes": text], merge: true) { _ in }
    }

    private static let itineraryMarker = "✨ Your AI travel plan"

    private static func notesText(from itinerary: Itinerary) -> String {
        var lines = [itineraryMarker, ""]
        for day in itinerary.days {
            lines.append("Day \(day.dayNumber) · \(day.title)")
            lines.append("• Morning: \(day.morning)")
            lines.append("• Afternoon: \(day.afternoon)")
            lines.append("• Evening: \(day.evening)")
            lines.append("• Dining: \(day.dining)")
            lines.append("")
        }
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Legacy migration (one-time, tiny pre-launch user base)

    private func migrateIfNeeded(into ref: DocumentReference, uid: String, coupleId: String?) async {
        let parentSnap = try? await ref.getDocument()

        // The active doc still holds old array-format data -> migrate it in place.
        if let data = parentSnap?.data(), hasLegacyArrays(data) {
            migrateArrays(from: data, into: ref)
            return
        }

        // Couple path with nothing yet -> seed from this user's legacy per-user plan.
        if coupleId != nil, !(parentSnap?.exists ?? false) {
            let legacyRef = db.collection("users").document(uid)
                .collection("trips").document(plan.destinationId)
            if let legacy = try? await legacyRef.getDocument(), legacy.exists, let data = legacy.data() {
                if let ts = data["startDate"] as? Timestamp { ref.setData(["startDate": ts], merge: true) { _ in } }
                if let notes = data["notes"] as? String { ref.setData(["notes": notes], merge: true) { _ in } }
                migrateArrays(from: data, into: ref)
            }
        }
    }

    private func hasLegacyArrays(_ data: [String: Any]) -> Bool {
        let budget = data["budgetItems"] as? [[String: Any]] ?? []
        let checklist = data["checklist"] as? [[String: Any]] ?? []
        return !budget.isEmpty || !checklist.isEmpty
    }

    private func migrateArrays(from data: [String: Any], into ref: DocumentReference) {
        let now = Date().timeIntervalSince1970
        if let raw = data["budgetItems"] as? [[String: Any]] {
            for (offset, dict) in raw.enumerated() {
                let id = dict["id"] as? String ?? UUID().uuidString
                let item = BudgetItem(
                    id: id,
                    title: dict["title"] as? String ?? "",
                    amountUSD: dict["amountUSD"] as? Double ?? 0,
                    createdAt: dict["createdAt"] as? Double ?? now + Double(offset)
                )
                try? ref.collection("budget").document(id).setData(from: item)
            }
        }
        if let raw = data["checklist"] as? [[String: Any]] {
            for (offset, dict) in raw.enumerated() {
                let id = dict["id"] as? String ?? UUID().uuidString
                let item = ChecklistItem(
                    id: id,
                    title: dict["title"] as? String ?? "",
                    done: dict["done"] as? Bool ?? false,
                    createdAt: dict["createdAt"] as? Double ?? now + Double(offset)
                )
                try? ref.collection("checklist").document(id).setData(from: item)
            }
        }
        // Drop the legacy arrays so migration doesn't run again.
        ref.updateData(["budgetItems": FieldValue.delete(), "checklist": FieldValue.delete()])
    }
}
