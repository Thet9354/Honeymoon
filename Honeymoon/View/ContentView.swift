//
//  ContentView.swift
//  Honeymoon
//
//  Created by Phoon Thet Pine on 31/10/23.
//

import SwiftUI

struct ContentView: View {

    // MARK: - ENVIRONMENT
    @EnvironmentObject private var destinationStore: DestinationStore
    @EnvironmentObject private var userDataStore: UserDataStore
    @EnvironmentObject private var preferenceStore: PreferenceStore
    @EnvironmentObject private var coupleStore: CoupleStore
    @EnvironmentObject private var purchaseStore: PurchaseStore

    // MARK: - PROPERTIES
    @State var showAlert: Bool = false
    /// True only the first time the user ever books, so the celebration shows once.
    @AppStorage("hasBookedBefore") private var hasBookedBefore: Bool = false
    @AppStorage("hasUsedFreeItinerary") private var hasUsedFreeItinerary = false
    @State private var bookingIsFirst: Bool = false
    @State var showGuide: Bool = false
    @State var showSettings: Bool = false
    @State var showSaved: Bool = false
    @State var showCouple: Bool = false
    @State private var detailDestination: Destination?
    /// Drives the "Plan together" routing from the match celebration.
    @State private var matchPlanDestination: Destination?
    @State private var showMatchPaywall = false
    @GestureState private var dragState = DragState.inactive
    private var dragAreaThreshold: CGFloat = 65.0
    @State private var lastCardIndex: Int = 1
    @State private var cardRemovalTransition = AnyTransition.trailingBottom
    /// Toggles when the drag passes the like/pass threshold (drives a haptic tick).
    @State private var thresholdCrossed = false
    /// Increments each time a card is committed (drives a haptic thump).
    @State private var swipeCommitCount = 0

    // MARK: - CARD VIEWS
    @State var cardViews: [CardView] = []

    // MARK: MOVE THE CARD

    // Destinations ranked by the user's stated preferences (P2). Falls back to
    // the catalog's natural order when no preferences are set.
    private var orderedDestinations: [Destination] {
        preferenceStore.ranked(destinationStore.destinations)
    }

    private func moveCards() {
        let destinations = orderedDestinations
        guard !destinations.isEmpty else { return }
        SoundPlayer.shared.play(.swipe)
        cardViews.removeFirst()

        self.lastCardIndex += 1

        let destination = destinations[lastCardIndex % destinations.count]

        let newCardView = CardView(
            destination: destination,
            reason: preferenceStore.preferences.rationale(for: destination)
        )

        cardViews.append(newCardView)
    }

    // MARK: SEED CARDS

    private func seedCardsIfNeeded() {
        guard cardViews.isEmpty else { return }
        let destinations = orderedDestinations
        guard destinations.count >= 2 else { return }
        cardViews = [
            CardView(destination: destinations[0],
                     reason: preferenceStore.preferences.rationale(for: destinations[0])),
            CardView(destination: destinations[1],
                     reason: preferenceStore.preferences.rationale(for: destinations[1]))
        ]
        lastCardIndex = 1
    }

    // Rebuild the deck from the top — used when preferences change so the
    // re-ranked order takes effect immediately.
    private func reseed() {
        cardViews = []
        lastCardIndex = 1
        seedCardsIfNeeded()
    }

    // MARK: TOP CARD
    private func isTopCard(cardView: CardView) -> Bool {
        guard let index = cardViews.firstIndex(where: { $0.id == cardView.id}) else {
            return false
        }
        return index == 0
    }

    // MARK: - CARD INTERACTION HELPERS

    /// Top card: a gentle press-in while touched. Card behind: eases up to full
    /// size as the top card is dragged away, giving the deck a sense of depth.
    private func cardScale(for cardView: CardView) -> CGFloat {
        if isTopCard(cardView: cardView) {
            return dragState.isPressing ? 0.97 : 1.0
        }
        let progress = min(abs(dragState.translation.width) / 180, 1)
        return 0.92 + 0.08 * progress
    }

    /// Gradual opacity for the like/pass stamp, ramping up to the threshold.
    private func stampOpacity(for cardView: CardView, liked: Bool) -> Double {
        guard isTopCard(cardView: cardView) else { return 0 }
        let width = dragState.translation.width
        let directional = liked ? max(width, 0) : max(-width, 0)
        return Double(min(directional / dragAreaThreshold, 1))
    }

    /// Header/footer fade out smoothly as the top card is dragged.
    private var chromeOpacity: Double {
        1 - Double(min(abs(dragState.translation.width) / 150, 1))
    }

    // MARK: DRAG STATES
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }

        var isDragging: Bool {
            switch self {
            case .dragging:
                return true
            case .pressing, .inactive:
                return false
            }
        }

        var isPressing: Bool {
            switch self {
            case .pressing, .dragging:
                return true
            case .inactive:
                return false
            }
        }
    }

    var body: some View {
        VStack {
            // MARK: - HEADER
            HeaderView(showGuideView: $showGuide, showSettingsView: $showSettings, showSavedView: $showSaved, showCoupleView: $showCouple)
                .opacity(chromeOpacity)
                .animation(.easeOut(duration: 0.25), value: dragState.translation)

            Spacer()

            // MARK: - CARDS

            ZStack {
                ForEach(cardViews) { cardView in
                    cardView
                        .zIndex(self.isTopCard(cardView: cardView) ? 1 : 0)
                        .overlay(
                            ZStack {
                                // X-MARK SYMBOL
                                Image(systemName: "x.circle")
                                    .modifier(SymbolModifier())
                                    .opacity(self.stampOpacity(for: cardView, liked: false))

                                // HEART SYMBOL
                                Image(systemName: "heart.circle")
                                    .modifier(SymbolModifier())
                                    .opacity(self.stampOpacity(for: cardView, liked: true))
                            }
                        )
                        .offset(x: self.isTopCard(cardView: cardView) ? self.dragState.translation.width : 0, y: self.isTopCard(cardView: cardView) ? self.dragState.translation.height : 0)
                        .scaleEffect(self.cardScale(for: cardView))
                        .rotationEffect(
                            .degrees(self.isTopCard(cardView: cardView) ? Double(self.dragState.translation.width / 18) : 0),
                            anchor: .bottom
                        )
                        // Finger-tracking spring for movement; gentle spring for the press.
                        .animation(.interactiveSpring(response: 0.32, dampingFraction: 0.74), value: dragState.translation)
                        .animation(.spring(response: 0.34, dampingFraction: 0.7), value: dragState.isPressing)
                        .gesture(LongPressGesture(minimumDuration: 0.01)
                            .sequenced(before: DragGesture())
                            .updating(self.$dragState, body: { (value, state, transaction) in
                                switch value {
                                case .first(true):
                                    state = .pressing
                                case .second(true, let drag):
                                    state = .dragging(translation: drag?.translation ?? .zero)
                                default:
                                    break
                            }
                        })
                                .onChanged({ (value) in
                                    guard case .second(true, let drag?) = value else {
                                        return
                                    }

                                    // Fire a single haptic tick the moment the drag
                                    // crosses the like/pass threshold (either way).
                                    let crossed = abs(drag.translation.width) > self.dragAreaThreshold
                                    if crossed != self.thresholdCrossed {
                                        self.thresholdCrossed = crossed
                                    }

                                    if drag.translation.width < -self.dragAreaThreshold {
                                        self.cardRemovalTransition = .leadingBottom
                                    }

                                    if drag.translation.width > self.dragAreaThreshold {
                                        self.cardRemovalTransition = .trailingBottom
                                    }
                                })
                                .onEnded({ (value) in
                                    self.thresholdCrossed = false
                                    guard case .second(true, let drag?) = value else {
                                        return
                                    }

                                    if drag.translation.width > self.dragAreaThreshold {
                                        // Swipe right = save to favorites, and record
                                        // the like for couple matching when linked.
                                        if let destination = self.cardViews.first?.destination {
                                            self.userDataStore.addFavorite(destination)
                                            self.coupleStore.recordLike(destination)
                                        }
                                        self.swipeCommitCount += 1
                                        self.moveCards()
                                    } else if drag.translation.width < -self.dragAreaThreshold {
                                        self.swipeCommitCount += 1
                                        self.moveCards()
                                    }
                                })
                    )
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                if self.isTopCard(cardView: cardView) {
                                    self.detailDestination = cardView.destination
                                }
                            }
                        )
                        .transition(self.cardRemovalTransition)
                }
            }
            .padding(.horizontal)
            .sensoryFeedback(.selection, trigger: thresholdCrossed)
            .sensoryFeedback(.impact(weight: .medium), trigger: swipeCommitCount)

            Spacer()

            // MARK: - FOOTER

            FooterView(showBookingAlert: $showAlert, onBook: {
                if let destination = cardViews.first?.destination {
                    userDataStore.addBooking(destination)
                }
                // Celebrate only the first booking ever; afterwards a brief note.
                bookingIsFirst = !hasBookedBefore
                hasBookedBefore = true
            })
                .opacity(chromeOpacity)
                .animation(.easeOut(duration: 0.25), value: dragState.translation)
        }
        .task {
            await destinationStore.load()
            seedCardsIfNeeded()
        }
        .onChange(of: preferenceStore.preferences) {
            reseed()
        }
        .alert(isPresented: $showAlert) {
            if bookingIsFirst {
                Alert(
                    title: Text("SUCCESS"),
                    message: Text("Wishing a lovely and most precious of times together for the amazing couple."),
                    dismissButton: .default(Text("Happy Honeymoon!"))
                )
            } else {
                Alert(
                    title: Text("Added to your bookings"),
                    message: Text("Find it in Saved to start planning your trip."),
                    dismissButton: .default(Text("Done"))
                )
            }
        }
        .sheet(item: $detailDestination) { destination in
            DestinationDetailView(destination: destination)
                .environmentObject(userDataStore)
        }
        .fullScreenCover(item: $coupleStore.pendingMatch) { match in
            MatchCelebrationView(
                match: match,
                onDismiss: { coupleStore.pendingMatch = nil },
                onPlan: {
                    // Sell at peak intent: route premium couples straight to the
                    // shared plan, free couples to the paywall.
                    let destination = destinationStore.destinations.first { $0.id == match.id }
                    coupleStore.pendingMatch = nil
                    Task {
                        // Let the cover finish dismissing before presenting the next sheet.
                        try? await Task.sleep(nanoseconds: 350_000_000)
                        guard let destination else { return }
                        // Premium (or a free user's one preview) opens the plan;
                        // otherwise the paywall at peak intent.
                        if purchaseStore.isPremium || !hasUsedFreeItinerary {
                            matchPlanDestination = destination
                        } else {
                            showMatchPaywall = true
                        }
                    }
                }
            )
        }
        .sheet(item: $matchPlanDestination) { destination in
            ItineraryView(destination: destination)
        }
        .sheet(isPresented: $showMatchPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DestinationStore())
        .environmentObject(UserDataStore())
        .environmentObject(PreferenceStore())
        .environmentObject(CoupleStore())
        .environmentObject(PurchaseStore())
        .environmentObject(ItineraryService())
}
