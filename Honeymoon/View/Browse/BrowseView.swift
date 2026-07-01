//
//  BrowseView.swift
//  Honeymoon
//
//  Explore: a searchable, filterable list of the full destination catalogue.
//  The swipe deck is for discovery; this lets couples navigate all 40+ places
//  directly by name, region, budget, or flight length. Tapping a row opens the
//  same detail screen used elsewhere.
//

import SwiftUI

struct BrowseView: View {

    @EnvironmentObject private var destinationStore: DestinationStore
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var selectedRegions: Set<String> = []
    @State private var budget: BudgetBand?
    @State private var sort: SortOption = .featured
    @State private var detail: Destination?

    enum SortOption: String, CaseIterable, Identifiable {
        case featured = "Featured"
        case topRated = "Top rated"
        case priceLow = "Price: low to high"
        case shortestFlight = "Shortest flight"
        var id: String { rawValue }
    }

    // MARK: - Filtering

    private var results: [Destination] {
        var items = destinationStore.destinations

        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        if !q.isEmpty {
            items = items.filter { d in
                d.place.lowercased().contains(q)
                    || d.country.lowercased().contains(q)
                    || d.region.lowercased().contains(q)
                    || d.tags.contains { $0.lowercased().contains(q) }
            }
        }
        if !selectedRegions.isEmpty {
            items = items.filter { selectedRegions.contains($0.region) }
        }
        if let budget {
            items = items.filter { budget.contains($0.estBudgetForTwoUSD) }
        }

        switch sort {
        case .featured:       break
        case .topRated:       items.sort { $0.rating > $1.rating }
        case .priceLow:       items.sort { $0.estBudgetForTwoUSD < $1.estBudgetForTwoUSD }
        case .shortestFlight: items.sort { $0.flightHours < $1.flightHours }
        }
        return items
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                filterBar
                Divider()
                listOrEmpty
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search destinations")
            .tint(Color.brand)
            .sheet(item: $detail) { destination in
                DestinationDetailView(destination: destination)
            }
        }
        .task { await destinationStore.load() }
        .appAppearance()
    }

    // MARK: - Filter bar

    private var filterBar: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TravelPreferences.allRegions, id: \.self) { region in
                        chip(region, selected: selectedRegions.contains(region)) {
                            if selectedRegions.contains(region) { selectedRegions.remove(region) }
                            else { selectedRegions.insert(region) }
                        }
                    }
                }
                .padding(.horizontal)
            }

            HStack(spacing: 10) {
                Menu {
                    Picker("Budget", selection: $budget) {
                        Text("Any budget").tag(BudgetBand?.none)
                        ForEach(BudgetBand.allCases) { band in
                            Text(band.label).tag(BudgetBand?.some(band))
                        }
                    }
                } label: {
                    filterLabel(budget?.label ?? "Any budget", icon: "wallet.pass")
                }

                Menu {
                    Picker("Sort", selection: $sort) {
                        ForEach(SortOption.allCases) { Text($0.rawValue).tag($0) }
                    }
                } label: {
                    filterLabel(sort.rawValue, icon: "arrow.up.arrow.down")
                }

                Spacer()

                Text("\(results.count)")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
    }

    private func chip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(selected ? Color.brand.opacity(0.15) : Color(.secondarySystemBackground), in: Capsule())
                .overlay(Capsule().stroke(selected ? Color.brand : .clear, lineWidth: 1.5))
                .foregroundStyle(selected ? Color.brand : .primary)
        }
        .buttonStyle(.plain)
    }

    private func filterLabel(_ text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text).lineLimit(1)
            Image(systemName: "chevron.down").font(.caption2)
        }
        .font(.subheadline)
        .padding(.horizontal, 12).padding(.vertical, 7)
        .background(Color(.secondarySystemBackground), in: Capsule())
        .foregroundStyle(.primary)
    }

    // MARK: - List

    @ViewBuilder
    private var listOrEmpty: some View {
        if destinationStore.destinations.isEmpty {
            Spacer()
            ProgressView().controlSize(.large).tint(Color.brand)
            Spacer()
        } else if results.isEmpty {
            emptyResults
        } else {
            List(results) { destination in
                Button { detail = destination } label: { row(destination) }
                    .buttonStyle(.plain)
            }
            .listStyle(.plain)
        }
    }

    private func row(_ d: Destination) -> some View {
        HStack(spacing: 14) {
            Image(d.image)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(d.place).font(.headline)
                Text(d.country).font(.subheadline).foregroundStyle(.secondary)
                HStack(spacing: 10) {
                    if d.rating > 0 {
                        Label(String(format: "%.1f", d.rating), systemImage: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                    if d.flightHours > 0 {
                        Label(d.flightDisplay, systemImage: "airplane")
                    }
                    if d.estBudgetForTwoUSD > 0 {
                        Text(d.budgetDisplay)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private var emptyResults: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Color.brand.opacity(0.6))
            Text("No matches")
                .font(.system(.title3, design: .rounded).weight(.semibold))
            Text("Try a different search or clear your filters.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if !selectedRegions.isEmpty || budget != nil || !query.isEmpty {
                Button("Clear filters") {
                    query = ""; selectedRegions = []; budget = nil
                }
                .font(.subheadline.weight(.semibold))
                .tint(Color.brand)
                .padding(.top, 4)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    BrowseView()
        .environmentObject(DestinationStore())
        .environmentObject(UserDataStore())
        .environmentObject(PurchaseStore())
        .environmentObject(PreferenceStore())
}
