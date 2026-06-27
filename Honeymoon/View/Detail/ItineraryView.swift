//
//  ItineraryView.swift
//  Honeymoon
//
//  Stage A: the unlocked Premium itinerary — a personalized, Claude-generated
//  day-by-day plan plus a budget breakdown. Loads asynchronously via
//  `ItineraryService` (cache-first, then the Cloud Function, then a deterministic
//  fallback). Reached from the detail screen once the user has Premium.
//

import SwiftUI

struct ItineraryView: View {

    let destination: Destination
    /// Optional trip start date to tailor the plan to the season.
    var startDate: Date? = nil

    @EnvironmentObject private var itineraryService: ItineraryService
    @EnvironmentObject private var preferenceStore: PreferenceStore
    @Environment(\.dismiss) private var dismiss
    // Held so the budget re-renders when the user switches currency.
    @AppStorage("currency") private var currencyRaw = Currency.sgd.rawValue

    @State private var itinerary: Itinerary?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if let itinerary {
                    itineraryList(itinerary)
                } else {
                    loadingState
                }
            }
            .navigationTitle(destination.place)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await load(force: true) }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                    .accessibilityLabel("Regenerate itinerary")
                }
            }
            .tint(Color.pink)
        }
        .task {
            if itinerary == nil { await load(force: false) }
        }
    }

    // MARK: - Loading

    private func load(force: Bool) async {
        isLoading = true
        let result = await itineraryService.itinerary(
            for: destination,
            preferences: preferenceStore.preferences,
            startDate: startDate,
            forceRegenerate: force
        )
        itinerary = result
        isLoading = false
    }

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(Color.pink)
            Text("Crafting your personalized plan…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Itinerary

    private func itineraryList(_ itinerary: Itinerary) -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(itinerary.days.count)-day honeymoon")
                        .font(.title3.weight(.bold))
                    Text("A romantic day-by-day plan for \(destination.place), \(destination.country), tailored to your tastes.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            ForEach(itinerary.days) { day in
                Section {
                    beat(icon: "sunrise", label: "Morning", text: day.morning)
                    beat(icon: "sun.max", label: "Afternoon", text: day.afternoon)
                    beat(icon: "moon.stars", label: "Evening", text: day.evening)
                    beat(icon: "fork.knife", label: "Dining", text: day.dining)
                } header: {
                    Text("Day \(day.dayNumber) · \(day.title)")
                }
            }

            if !itinerary.budget.isEmpty {
                Section {
                    ForEach(itinerary.budget) { line in
                        HStack {
                            Text(line.category)
                            Spacer()
                            Text(line.display).foregroundStyle(.secondary)
                        }
                    }
                    HStack {
                        Text("Estimated total").fontWeight(.semibold)
                        Spacer()
                        Text(itinerary.budgetTotalDisplay).fontWeight(.semibold)
                    }
                } header: {
                    Text("Budget for two")
                } footer: {
                    Text("Indicative only — actual prices vary by season and how you book.")
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func beat(icon: String, label: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.pink)
                .frame(width: 24, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(text)
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ItineraryView(destination: honeymoonData[0])
        .environmentObject(ItineraryService())
        .environmentObject(PreferenceStore())
}
