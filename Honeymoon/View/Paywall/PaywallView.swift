//
//  PaywallView.swift
//  Honeymoon
//
//  P5: the Premium upsell. Presented contextually when a free user taps a
//  locked feature (e.g. the itinerary), and from Settings. Leads with the
//  one-time Lifetime unlock; offers an Annual subscription (with free trial)
//  as the alternative.
//

import SwiftUI
import StoreKit

struct PaywallView: View {

    @EnvironmentObject private var purchaseStore: PurchaseStore
    @Environment(\.dismiss) private var dismiss

    @State private var purchasingID: String?

    private var isPurchasing: Bool { purchasingID != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    header
                    benefits
                    plans
                    restoreButton
                    legalFooter
                }
                .padding(20)
            }
            .navigationTitle("Honeymoon Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.subheadline.weight(.semibold))
                    }
                    .tint(.secondary)
                }
            }
            .tint(Color.pink)
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { purchaseStore.purchaseError != nil },
                    set: { if !$0 { purchaseStore.purchaseError = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(purchaseStore.purchaseError ?? "")
            }
        }
        .onChange(of: purchaseStore.isPremium) { _, premium in
            if premium { dismiss() }
        }
        .appAppearance()
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 56, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.pink)
            Text("Plan the perfect honeymoon")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)
            Text("Unlock AI-personalized day-by-day itineraries built around your tastes, budget, and travel dates.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Benefits

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 14) {
            benefitRow("sparkles", "AI-personalized itineraries", "Day-by-day plans written for you two — with dining picks and a full budget breakdown.")
            benefitRow("wand.and.stars", "Smarter recommendations", "Your deck, tuned more closely to what you both love.")
            benefitRow("heart.text.square", "Plan without limits", "Rich trip plans for every destination on your shortlist.")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func benefitRow(_ icon: String, _ title: String, _ subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.pink)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Plans

    private var plans: some View {
        VStack(spacing: 12) {
            if purchaseStore.products.isEmpty {
                if purchaseStore.isLoadingProducts {
                    ProgressView().padding(.vertical, 20)
                } else {
                    Text("Purchase options are unavailable right now.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 12)
                }
            } else {
                if let lifetime = purchaseStore.lifetimeProduct {
                    planButton(
                        product: lifetime,
                        headline: "Lifetime",
                        priceLine: "\(lifetime.displayPrice) once",
                        caption: "Pay once, yours forever",
                        highlighted: true
                    )
                }
                if let annual = purchaseStore.annualProduct {
                    planButton(
                        product: annual,
                        headline: "Annual",
                        priceLine: annualPriceLine(annual),
                        caption: trialCaption(annual),
                        highlighted: false
                    )
                }
            }
        }
    }

    private func planButton(product: Product, headline: String, priceLine: String, caption: String?, highlighted: Bool) -> some View {
        Button {
            buy(product)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(headline).font(.headline)
                    if let caption {
                        Text(caption)
                            .font(.caption)
                            .foregroundStyle(highlighted ? .white.opacity(0.85) : .secondary)
                    }
                }
                Spacer()
                if purchasingID == product.id {
                    ProgressView()
                        .tint(highlighted ? .white : .pink)
                } else {
                    Text(priceLine)
                        .font(.subheadline.weight(.semibold))
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
        }
        .background(
            highlighted ? Color.pink : Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .foregroundStyle(highlighted ? .white : .primary)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(highlighted ? Color.clear : Color(.separator), lineWidth: 0.5)
        )
        .disabled(isPurchasing)
    }

    private func annualPriceLine(_ product: Product) -> String {
        "\(product.displayPrice)/yr"
    }

    /// "7-day free trial, then …" when the annual product carries an intro offer.
    private func trialCaption(_ product: Product) -> String? {
        guard let offer = product.subscription?.introductoryOffer,
              offer.paymentMode == .freeTrial else {
            return "Billed yearly"
        }
        let unit = offer.period.unit
        let count = offer.period.value
        let unitName: String
        switch unit {
        case .day:   unitName = count == 1 ? "day" : "days"
        case .week:  unitName = count == 1 ? "week" : "weeks"
        case .month: unitName = count == 1 ? "month" : "months"
        case .year:  unitName = count == 1 ? "year" : "years"
        @unknown default: unitName = "days"
        }
        return "\(count)-\(unitName) free trial, then billed yearly"
    }

    // MARK: - Restore & legal

    private var restoreButton: some View {
        Button("Restore purchases") {
            Task { await purchaseStore.restore() }
        }
        .font(.subheadline)
        .tint(.pink)
        .disabled(isPurchasing)
    }

    private var legalFooter: some View {
        VStack(spacing: 8) {
            Text("The annual plan renews automatically unless cancelled at least 24 hours before the end of the period. Manage or cancel anytime in your Apple ID settings. The Lifetime option is a one-time purchase.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                NavigationLink("Terms") { LegalView(document: .termsOfService) }
                NavigationLink("Privacy") { LegalView(document: .privacyPolicy) }
            }
            .font(.caption2)
            .tint(.pink)
        }
        .padding(.top, 4)
    }

    // MARK: - Actions

    private func buy(_ product: Product) {
        purchasingID = product.id
        Task {
            await purchaseStore.purchase(product)
            purchasingID = nil
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(PurchaseStore())
}
