//
//  DestinationDetailView.swift
//  Honeymoon
//
//  P1: the rich destination detail screen. Surfaces enriched destination
//  content plus the hooks that later phases build on — favorite/booking
//  (existing), outbound hotel/experience search (P5 adds affiliate IDs),
//  and a locked premium itinerary teaser (P5 paywall).
//

import SwiftUI
import MapKit
import CoreLocation

struct DestinationDetailView: View {

    let destination: Destination

    @EnvironmentObject private var userDataStore: UserDataStore
    @EnvironmentObject private var purchaseStore: PurchaseStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var showBookingConfirmation = false
    @State private var showPaywall = false
    @State private var showItinerary = false
    // Held so the "For two" budget re-renders when the user switches currency.
    @AppStorage("currency") private var currencyRaw = Currency.sgd.rawValue
    // One free AI itinerary preview for non-premium users.
    @AppStorage("hasUsedFreeItinerary") private var hasUsedFreeItinerary = false

    /// Premium users always; free users until they've used their one preview.
    private var canOpenItinerary: Bool { purchaseStore.isPremium || !hasUsedFreeItinerary }

    private var isFavorite: Bool { userDataStore.isFavorite(destination) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                hero
                content
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topLeading) { closeButton }
        .background(Color(.systemBackground))
        .alert("Added to your trip", isPresented: $showBookingConfirmation) {
            Button("Lovely!", role: .cancel) {}
        } message: {
            Text("\(destination.place) is saved to your bookings. Open Saved to see all your plans.")
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(isPresented: $showItinerary) { ItineraryView(destination: destination) }
        .appAppearance()
    }

    // MARK: - Hero

    private var hero: some View {
        Image(destination.image)
            .resizable()
            .scaledToFill()
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [.black.opacity(0.55), .clear, .clear, .black.opacity(0.35)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(destination.place)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                    Label(destination.country, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .shadow(radius: 3)
                .padding(20)
            }
            .overlay(alignment: .topTrailing) { actionButtons }
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            circleButton(systemName: isFavorite ? "heart.fill" : "heart",
                         tint: isFavorite ? .pink : .primary) {
                if isFavorite {
                    userDataStore.removeFavorite(destination.id)
                } else {
                    userDataStore.addFavorite(destination)
                }
            }
        }
        .padding(.top, 56)
        .padding(.trailing, 16)
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 36, height: 36)
                .background(.regularMaterial, in: Circle())
        }
        .padding(.top, 56)
        .padding(.leading, 16)
        .accessibilityLabel("Back")
    }

    // MARK: - Content

    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            ratingRow
            quickFacts
            if !destination.summary.isEmpty {
                Text(destination.summary)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            if !destination.highlights.isEmpty { highlightsSection }
            mapSection
            itineraryTeaser
            bookingLinks
            bookButton
        }
        .padding(20)
    }

    private var ratingRow: some View {
        HStack(spacing: 6) {
            if destination.rating > 0 {
                Image(systemName: "star.fill").foregroundStyle(.yellow)
                Text(String(format: "%.1f", destination.rating))
                    .fontWeight(.semibold)
            }
            if !destination.region.isEmpty {
                Text("·").foregroundStyle(.secondary)
                Text(destination.region).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .font(.subheadline)
    }

    private var quickFacts: some View {
        HStack(spacing: 10) {
            factCard(icon: "sun.max", label: "Best", value: destination.bestSeason.isEmpty ? "—" : destination.bestSeason)
            factCard(icon: "wallet.pass", label: "For two", value: destination.budgetDisplay)
            factCard(icon: "airplane", label: "Flight", value: destination.flightDisplay)
        }
    }

    private func factCard(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Romantic highlights")
                .font(.headline)
            FlowChips(items: destination.highlights)
        }
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Where you're headed")
                .font(.headline)
            DestinationMapView(place: destination.place, country: destination.country)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
                .accessibilityLabel("Map of \(destination.place), \(destination.country)")
        }
    }

    private var itineraryTeaser: some View {
        Button {
            if canOpenItinerary {
                showItinerary = true
            } else {
                showPaywall = true
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("AI honeymoon itinerary", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    itineraryBadge
                }
                Text(itineraryTeaserSubtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var itineraryBadge: some View {
        if purchaseStore.isPremium {
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        } else if !hasUsedFreeItinerary {
            Label("Free preview", systemImage: "sparkles")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 9).padding(.vertical, 4)
                .background(Color.pink.opacity(0.15), in: Capsule())
                .foregroundStyle(Color.pink)
        } else {
            Label("Premium", systemImage: "lock.fill")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 9).padding(.vertical, 4)
                .background(Color.purple.opacity(0.15), in: Capsule())
                .foregroundStyle(.purple)
        }
    }

    private var itineraryTeaserSubtitle: String {
        if purchaseStore.isPremium {
            return "A personalized day-by-day plan with dining picks and a full budget breakdown."
        } else if !hasUsedFreeItinerary {
            return "Try one free — a personalized day-by-day plan, dining picks and a full budget breakdown."
        } else {
            return "A personalized day-by-day plan, dining picks and a full budget breakdown — unlock with Premium."
        }
    }

    private var bookingLinks: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Book your honeymoon")
                .font(.headline)
            HStack(spacing: 10) {
                outboundButton(title: "Find hotels", icon: "bed.double", url: AffiliateLinks.hotels(for: destination))
                outboundButton(title: "Experiences", icon: "ticket", url: AffiliateLinks.experiences(for: destination))
            }
            Text("Search our trusted travel partners — rates for two.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var bookButton: some View {
        Button {
            userDataStore.addBooking(destination)
            SoundPlayer.shared.play(.booking)
            showBookingConfirmation = true
        } label: {
            Label("Add to our trip", systemImage: "calendar.badge.plus")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .background(Color.pink, in: RoundedRectangle(cornerRadius: 14))
        .foregroundStyle(.white)
    }

    // MARK: - Helpers

    private func circleButton(systemName: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(.regularMaterial, in: Circle())
        }
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
    }

    private func outboundButton(title: String, icon: String, url: URL?) -> some View {
        Button {
            if let url { openURL(url) }
        } label: {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .foregroundStyle(.primary)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
    }
}

// MARK: - Destination map snippet

/// A small, non-interactive map for the destination. Resolves the coordinate from
/// the place name via the system geocoder, so no per-destination coordinates need
/// to be stored. Falls back to a neutral placeholder if geocoding fails.
private struct DestinationMapView: View {
    let place: String
    let country: String

    @State private var coordinate: CLLocationCoordinate2D?
    @State private var position: MapCameraPosition = .automatic
    @State private var didResolve = false

    var body: some View {
        Group {
            if let coordinate {
                Map(position: $position, interactionModes: []) {
                    Marker(place, coordinate: coordinate).tint(.pink)
                }
            } else {
                ZStack {
                    Rectangle().fill(Color(.secondarySystemBackground))
                    Image(systemName: "map")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .task {
            guard !didResolve else { return }
            didResolve = true
            let geocoder = CLGeocoder()
            guard
                let placemark = try? await geocoder.geocodeAddressString("\(place), \(country)").first,
                let location = placemark.location
            else { return }
            coordinate = location.coordinate
            position = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
            ))
        }
    }
}

// MARK: - Flow layout for chips

/// Simple wrapping chip row. Uses iOS 16+ Layout for clean multi-line wrapping.
private struct FlowChips: View {
    let items: [String]

    var body: some View {
        FlowLayout(spacing: 6) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.footnote)
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(Color.pink.opacity(0.12), in: Capsule())
                    .foregroundStyle(Color.pink)
            }
        }
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0, rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0, totalWidth: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, rowWidth > 0 {
                totalHeight += rowHeight + spacing
                totalWidth = max(totalWidth, rowWidth - spacing)
                rowWidth = 0; rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        totalWidth = max(totalWidth, rowWidth - spacing)
        return CGSize(width: min(totalWidth, maxWidth), height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    DestinationDetailView(destination: honeymoonData[0])
        .environmentObject(UserDataStore())
        .environmentObject(PurchaseStore())
}
