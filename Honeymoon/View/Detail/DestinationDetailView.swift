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
import UIKit
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
    // Paged photo gallery state.
    @State private var selectedPhoto = 0
    @State private var showPhotoViewer = false
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
        .fullScreenCover(isPresented: $showPhotoViewer) {
            PhotoGalleryViewer(photos: photos, selection: $selectedPhoto)
        }
        .appAppearance()
    }

    // MARK: - Hero gallery

    private var photos: [Destination.PhotoRef] { destination.photos }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            photoPager
            LinearGradient(
                colors: [.black.opacity(0.55), .clear, .clear, .black.opacity(0.35)],
                startPoint: .top, endPoint: .bottom
            )
            .allowsHitTesting(false)
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
            .allowsHitTesting(false)
        }
        .frame(height: 300)
        .frame(maxWidth: .infinity)
        .clipped()
        .overlay(alignment: .topTrailing) { actionButtons }
        .overlay(alignment: .bottom) { pageIndicator }
    }

    @ViewBuilder
    private var photoPager: some View {
        if photos.count > 1 {
            TabView(selection: $selectedPhoto) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, ref in
                    GalleryPhoto(ref: ref, contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onTapGesture { showPhotoViewer = true }
        } else {
            GalleryPhoto(ref: photos.first ?? .asset(destination.image), contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .onTapGesture { showPhotoViewer = true }
        }
    }

    @ViewBuilder
    private var pageIndicator: some View {
        if photos.count > 1 {
            HStack(spacing: 6) {
                ForEach(photos.indices, id: \.self) { index in
                    Circle()
                        .fill(.white.opacity(index == selectedPhoto ? 0.95 : 0.45))
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.black.opacity(0.25), in: Capsule())
            .padding(.bottom, 12)
            .allowsHitTesting(false)
        }
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
            DestinationMapView(
                place: destination.place,
                country: destination.country,
                latitude: destination.latitude,
                longitude: destination.longitude
            )
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
        }
        .buttonStyle(PrimaryButtonStyle())
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

/// A small, non-interactive map for the destination. Prefers the stored
/// coordinate (instant and reliable); only when none is provided does it fall
/// back to the rate-limited runtime geocoder. Shows a neutral placeholder while
/// resolving / if both fail.
private struct DestinationMapView: View {
    let place: String
    let country: String
    var latitude: Double?
    var longitude: Double?

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

            // Stored coordinate — instant, no network.
            if let latitude, let longitude {
                show(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                return
            }

            // Fallback: geocode from the place name (best-effort; may be throttled).
            let geocoder = CLGeocoder()
            guard
                let placemark = try? await geocoder.geocodeAddressString("\(place), \(country)").first,
                let location = placemark.location
            else { return }
            show(location.coordinate)
        }
    }

    private func show(_ center: CLLocationCoordinate2D) {
        coordinate = center
        position = .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
        ))
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

// MARK: - Gallery photo

/// Renders one gallery photo: a bundled asset directly, or a remote URL via a
/// disk-cached, retrying loader so remote photos load reliably and stay loaded.
/// Callers apply their own frame and clipping.
private struct GalleryPhoto: View {
    let ref: Destination.PhotoRef
    var contentMode: ContentMode = .fill

    var body: some View {
        switch ref {
        case .asset(let name):
            Image(name)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        case .remote(let url):
            RemoteGalleryImage(url: url, contentMode: contentMode)
        }
    }
}

/// A remote gallery image backed by `RemoteImageLoader` (disk + memory cache,
/// auto-retry). Shows a branded placeholder while loading and on final failure;
/// once an image is fetched it's cached, so paging back is instant.
private struct RemoteGalleryImage: View {
    let url: URL
    var contentMode: ContentMode = .fill
    @StateObject private var loader = RemoteImageLoader()

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder(systemImage: loader.didFail ? "photo" : nil)
            }
        }
        .task(id: url) { await loader.load(url) }
    }

    private func placeholder(systemImage: String?) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color.brand.opacity(0.25), Color.brand.opacity(0.08)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            } else {
                ProgressView()
            }
        }
    }
}

/// Loads remote images reliably: an in-memory `NSCache` for instant re-display,
/// a shared disk-backed `URLCache` that survives relaunches, and up to three
/// attempts with backoff so a transient hiccup (e.g. a `429`) doesn't strand the
/// placeholder. The fetch + decode run off the main actor.
@MainActor
final class RemoteImageLoader: ObservableObject {
    @Published private(set) var image: UIImage?
    @Published private(set) var didFail = false

    func load(_ url: URL) async {
        if let cached = remoteImageMemoryCache.object(forKey: url as NSURL) {
            image = cached
            didFail = false
            return
        }
        didFail = false

        let fetched = await fetchRemoteImage(url)
        if Task.isCancelled { return }
        if let fetched {
            image = fetched
            didFail = false
        } else {
            didFail = true
        }
    }
}

private let remoteImageMemoryCache: NSCache<NSURL, UIImage> = {
    let cache = NSCache<NSURL, UIImage>()
    cache.countLimit = 120
    return cache
}()

private let remoteImageSession: URLSession = {
    let config = URLSessionConfiguration.default
    config.urlCache = URLCache(memoryCapacity: 32 * 1024 * 1024,
                               diskCapacity: 256 * 1024 * 1024)
    config.requestCachePolicy = .returnCacheDataElseLoad
    config.waitsForConnectivity = true
    config.timeoutIntervalForRequest = 20
    config.timeoutIntervalForResource = 60
    return URLSession(configuration: config)
}()

/// Fetches and decodes a remote image off the main actor, retrying transient
/// failures, and caches the result in memory. Returns `nil` if all attempts fail.
private func fetchRemoteImage(_ url: URL) async -> UIImage? {
    for attempt in 0..<3 {
        if Task.isCancelled { return nil }
        do {
            var request = URLRequest(url: url)
            request.setValue(
                "HoneymoonApp/1.0 (https://github.com/Thet9354/Honeymoon)",
                forHTTPHeaderField: "User-Agent"
            )
            let (data, response) = try await remoteImageSession.data(for: request)
            if let http = response as? HTTPURLResponse,
               !(200..<300).contains(http.statusCode) {
                throw URLError(.badServerResponse)
            }
            guard let decoded = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            remoteImageMemoryCache.setObject(decoded, forKey: url as NSURL)
            return decoded
        } catch {
            if Task.isCancelled { return nil }
            if attempt < 2 {
                // Backoff: 0.6s, then 1.4s.
                try? await Task.sleep(nanoseconds: UInt64(600_000_000 + attempt * 800_000_000))
            }
        }
    }
    return nil
}

// MARK: - Full-screen photo viewer

/// A tap-to-open full-screen, swipeable viewer for a destination's photos.
private struct PhotoGalleryViewer: View {
    let photos: [Destination.PhotoRef]
    @Binding var selection: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            TabView(selection: $selection) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, ref in
                    GalleryPhoto(ref: ref, contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: photos.count > 1 ? .automatic : .never))
            .ignoresSafeArea()

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding()
            .accessibilityLabel("Close photo")
        }
    }
}

#Preview {
    DestinationDetailView(destination: honeymoonData[0])
        .environmentObject(UserDataStore())
        .environmentObject(PurchaseStore())
}
