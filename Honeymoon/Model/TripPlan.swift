//
//  TripPlan.swift
//  Honeymoon
//
//  P3: the planning detail for a booked destination — travel date (countdown),
//  budget line items, a packing checklist, and free-form notes. Persisted per
//  user in Firestore under users/{uid}/trips/{destinationId}.
//

import Foundation

struct BudgetItem: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var title: String
    var amountUSD: Double
}

struct ChecklistItem: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var title: String
    var done: Bool = false
}

struct TripPlan: Codable, Equatable {
    var destinationId: String
    var place: String
    var country: String
    var image: String
    var startDate: Date?
    var budgetItems: [BudgetItem] = []
    var checklist: [ChecklistItem] = []
    var notes: String = ""

    init(destinationId: String, place: String, country: String, image: String) {
        self.destinationId = destinationId
        self.place = place
        self.country = country
        self.image = image
    }
}

extension TripPlan {
    /// Total of all budget line items.
    var budgetTotal: Double {
        budgetItems.reduce(0) { $0 + $1.amountUSD }
    }

    /// Whole days from now until the trip start, or nil if no date set.
    /// Negative once the start date has passed.
    var daysUntilStart: Int? {
        guard let startDate else { return nil }
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let target = cal.startOfDay(for: startDate)
        return cal.dateComponents([.day], from: start, to: target).day
    }

    var checklistProgress: Double {
        guard !checklist.isEmpty else { return 0 }
        return Double(checklist.filter(\.done).count) / Double(checklist.count)
    }
}
