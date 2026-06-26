//
//  PreferenceQuizView.swift
//  Honeymoon
//
//  P2: a short taste quiz (interests, budget, regions) that personalizes the
//  swipe deck. Used as the final onboarding step and re-openable from Settings.
//

import SwiftUI

struct PreferenceQuizView: View {

    enum Mode { case onboarding, edit }

    let mode: Mode
    var onFinish: () -> Void = {}

    @EnvironmentObject private var preferenceStore: PreferenceStore
    @Environment(\.dismiss) private var dismiss

    @State private var draft = TravelPreferences()

    private let interestColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                if mode == .onboarding { header }
                interestsSection
                budgetSection
                regionsSection
            }
            .padding(20)
            .padding(.bottom, 96)
        }
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .bottom) { footer }
        .navigationTitle(mode == .edit ? "Travel preferences" : "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { draft = preferenceStore.preferences }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What's your dream trip?")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .foregroundStyle(Color.pink)
            Text("Pick what you love and we'll put the best matches first. You can change these anytime.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Your vibe", subtitle: "Choose any that fit")
            LazyVGrid(columns: interestColumns, spacing: 12) {
                ForEach(Interest.allCases) { interest in
                    interestCard(interest)
                }
            }
        }
    }

    private func interestCard(_ interest: Interest) -> some View {
        let selected = draft.interests.contains(interest)
        return Button {
            toggle(interest)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: interest.systemImage)
                    .font(.system(size: 18))
                    .frame(width: 24)
                Text(interest.label)
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14).padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 68, alignment: .leading)
            .background(selected ? Color.pink.opacity(0.15) : Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(selected ? Color.pink : .clear, lineWidth: 1.5)
            )
            .foregroundStyle(selected ? Color.pink : .primary)
        }
        .buttonStyle(.plain)
    }

    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Budget for two", subtitle: "Roughly, all-in")
            VStack(spacing: 0) {
                ForEach(BudgetBand.allCases) { band in
                    Button { toggle(band) } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(band.label).font(.subheadline.weight(.medium))
                                Text(band.detail).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: draft.budgetBand == band ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(draft.budgetBand == band ? Color.pink : Color(.tertiaryLabel))
                        }
                        .padding(.vertical, 12).padding(.horizontal, 14)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if band != BudgetBand.allCases.last {
                        Divider().padding(.leading, 14)
                    }
                }
            }
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private var regionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Regions", subtitle: "Anywhere you're dreaming of?")
            FlexibleChips(items: TravelPreferences.allRegions,
                          isSelected: { draft.regions.contains($0) },
                          onTap: toggleRegion)
        }
    }

    private func sectionTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 8) {
            Button { finish() } label: {
                Text(primaryTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            }
            .background(Color.pink, in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.white)

            if mode == .onboarding {
                Button("Skip for now") { finish(skip: true) }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.bar)
    }

    private var primaryTitle: String {
        switch mode {
        case .onboarding: draft.isEmpty ? "See all destinations" : "See my matches"
        case .edit:       "Save preferences"
        }
    }

    // MARK: - Actions

    private func toggle(_ interest: Interest) {
        if draft.interests.contains(interest) { draft.interests.remove(interest) }
        else { draft.interests.insert(interest) }
    }

    private func toggle(_ band: BudgetBand) {
        draft.budgetBand = (draft.budgetBand == band) ? nil : band
    }

    private func toggleRegion(_ region: String) {
        if draft.regions.contains(region) { draft.regions.remove(region) }
        else { draft.regions.insert(region) }
    }

    private func finish(skip: Bool = false) {
        if skip { draft = TravelPreferences() }
        preferenceStore.preferences = draft
        preferenceStore.markQuizCompleted()
        if mode == .edit { dismiss() }
        onFinish()
    }
}

// MARK: - Flexible wrapping chips

private struct FlexibleChips: View {
    let items: [String]
    let isSelected: (String) -> Bool
    let onTap: (String) -> Void

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(items, id: \.self) { item in
                let selected = isSelected(item)
                Button { onTap(item) } label: {
                    Text(item)
                        .font(.subheadline)
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(selected ? Color.pink.opacity(0.15) : Color(.secondarySystemBackground),
                                    in: Capsule())
                        .overlay(Capsule().stroke(selected ? Color.pink : .clear, lineWidth: 1.5))
                        .foregroundStyle(selected ? Color.pink : .primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0, rowHeight: CGFloat = 0, totalHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, rowWidth > 0 {
                totalHeight += rowHeight + spacing
                rowWidth = 0; rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: totalHeight + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    NavigationStack {
        PreferenceQuizView(mode: .onboarding)
            .environmentObject(PreferenceStore())
    }
}
