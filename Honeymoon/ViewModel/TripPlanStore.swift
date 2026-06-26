//
//  TripPlanStore.swift
//  Honeymoon
//
//  Loads and persists a single TripPlan document at
//  users/{uid}/trips/{destinationId}. Loads once on start, then writes through
//  on each edit (structured edits save immediately; notes save debounced).
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class TripPlanStore: ObservableObject {

    @Published var plan: TripPlan
    @Published private(set) var isLoading = false

    private var notesSaveTask: Task<Void, Never>?

    init(seed: TripPlan) {
        self.plan = seed
    }

    private var document: DocumentReference? {
        guard FirebaseApp.app() != nil, let uid = Auth.auth().currentUser?.uid else { return nil }
        return Firestore.firestore()
            .collection("users").document(uid)
            .collection("trips").document(plan.destinationId)
    }

    /// Fetches the existing plan once, keeping the seeded identity fields.
    func load() async {
        guard let document else { return }
        isLoading = true
        defer { isLoading = false }
        if let snapshot = try? await document.getDocument(),
           snapshot.exists,
           let existing = try? snapshot.data(as: TripPlan.self) {
            plan = existing
        }
    }

    // MARK: - Structured edits (save immediately)

    func setStartDate(_ date: Date?) {
        plan.startDate = date
        save()
    }

    func addBudgetItem(title: String, amount: Double) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        plan.budgetItems.append(BudgetItem(title: trimmed, amountUSD: amount))
        save()
    }

    func removeBudgetItems(at offsets: IndexSet) {
        plan.budgetItems.remove(atOffsets: offsets)
        save()
    }

    func addChecklistItem(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        plan.checklist.append(ChecklistItem(title: trimmed))
        save()
    }

    func toggleChecklistItem(_ item: ChecklistItem) {
        guard let index = plan.checklist.firstIndex(where: { $0.id == item.id }) else { return }
        plan.checklist[index].done.toggle()
        save()
    }

    func removeChecklistItems(at offsets: IndexSet) {
        plan.checklist.remove(atOffsets: offsets)
        save()
    }

    // MARK: - Notes (debounced save)

    func notesChanged() {
        notesSaveTask?.cancel()
        notesSaveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 800_000_000)
            guard !Task.isCancelled else { return }
            self?.save()
        }
    }

    // MARK: - Persistence

    private func save() {
        guard let document else { return }
        try? document.setData(from: plan, merge: true)
    }
}
