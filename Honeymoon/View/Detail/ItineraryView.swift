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
    @EnvironmentObject private var purchaseStore: PurchaseStore
    @EnvironmentObject private var userDataStore: UserDataStore
    @Environment(\.dismiss) private var dismiss
    // Held so the budget re-renders when the user switches currency.
    @AppStorage("currency") private var currencyRaw = Currency.sgd.rawValue
    // The one-time free AI itinerary preview for non-premium users.
    @AppStorage("hasUsedFreeItinerary") private var hasUsedFreeItinerary = false

    @State private var itinerary: Itinerary?
    @State private var isLoading = true
    @State private var showPaywall = false
    @State private var isAddingToTrip = false
    @State private var addedToTrip = false

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
                if purchaseStore.isPremium {
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
            }
            .tint(Color.pink)
            .sheet(isPresented: $showPaywall) { PaywallView() }
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
        itinerary = result.itinerary
        // A non-premium user "spends" their free preview only on a real AI plan.
        if !purchaseStore.isPremium, result.source != .fallback {
            hasUsedFreeItinerary = true
        }
        isLoading = false
    }

    /// Bridges the itinerary into the (shared) trip plan: books the destination so
    /// it appears in Saved, then seeds the trip's budget and notes from the plan.
    private func addToTrip(_ itinerary: Itinerary) async {
        isAddingToTrip = true
        userDataStore.addBooking(destination)
        let store = TripPlanStore(seed: TripPlan(
            destinationId: destination.id,
            place: destination.place,
            country: destination.country,
            image: destination.image
        ))
        await store.load()
        await store.applyItinerary(itinerary)
        isAddingToTrip = false
        addedToTrip = true
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

            Section {
                Button {
                    Task { await addToTrip(itinerary) }
                } label: {
                    HStack {
                        Label(addedToTrip ? "Added to your trip" : "Add to our trip plan",
                              systemImage: addedToTrip ? "checkmark.circle.fill" : "calendar.badge.plus")
                            .font(.headline)
                        Spacer()
                        if isAddingToTrip { ProgressView() }
                    }
                }
                .disabled(isAddingToTrip || addedToTrip)
                .foregroundStyle(addedToTrip ? Color.secondary : Color.pink)
            } footer: {
                Text("Saves the budget and day-by-day plan to your shared trip — find it in Saved to keep planning together.")
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

            if !purchaseStore.isPremium {
                Section { upgradeBanner }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var upgradeBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Your free preview", systemImage: "sparkles")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.pink)
            Text("Unlock Premium to generate a personalized plan for every destination on your shortlist.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button {
                showPaywall = true
            } label: {
                Text("Unlock Premium")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .background(Color.pink, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
        }
        .padding(.vertical, 4)
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
        .environmentObject(PurchaseStore())
        .environmentObject(UserDataStore())
}
