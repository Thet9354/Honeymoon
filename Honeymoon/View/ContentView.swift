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

    // MARK: - PROPERTIES
    @State var showAlert: Bool = false
    @State var showGuide: Bool = false
    @State var showSettings: Bool = false
    @State var showSaved: Bool = false
    @State private var detailDestination: Destination?
    @GestureState private var dragState = DragState.inactive
    private var dragAreaThreshold: CGFloat = 65.0
    @State private var lastCardIndex: Int = 1
    @State private var cardRemovalTransition = AnyTransition.trailingBottom

    // MARK: - CARD VIEWS
    @State var cardViews: [CardView] = []

    // MARK: MOVE THE CARD

    private func moveCards() {
        let destinations = destinationStore.destinations
        guard !destinations.isEmpty else { return }
        SoundPlayer.shared.play(.swipe)
        cardViews.removeFirst()

        self.lastCardIndex += 1

        let destination = destinations[lastCardIndex % destinations.count]

        let newCardView = CardView(destination: destination)

        cardViews.append(newCardView)
    }

    // MARK: SEED CARDS

    private func seedCardsIfNeeded() {
        guard cardViews.isEmpty else { return }
        let destinations = destinationStore.destinations
        guard destinations.count >= 2 else { return }
        cardViews = [
            CardView(destination: destinations[0]),
            CardView(destination: destinations[1])
        ]
        lastCardIndex = 1
    }

    // MARK: TOP CARD
    private func isTopCard(cardView: CardView) -> Bool {
        guard let index = cardViews.firstIndex(where: { $0.id == cardView.id}) else {
            return false
        }
        return index == 0
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
            HeaderView(showGuideView: $showGuide, showSettingsView: $showSettings, showSavedView: $showSaved)
                .opacity(dragState.isDragging ? 0.0 : 1.0)
                .animation(.default, value: dragState.isDragging)

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
                                    .opacity(self.dragState.translation.width < -self.dragAreaThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0.0)

                                // HEART SYMBOL
                                Image(systemName: "heart.circle")
                                    .modifier(SymbolModifier())
                                    .opacity(self.dragState.translation.width > self.dragAreaThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0.0)
                            }
                        )
                        .offset(x: self.isTopCard(cardView: cardView) ? self.dragState.translation.width : 0, y: self.isTopCard(cardView: cardView) ? self.dragState.translation.height : 0)
                        .scaleEffect(self.dragState.isDragging && self.isTopCard(cardView: cardView) ? 0.85 : 1.0)
                        .rotationEffect(Angle(degrees: self.isTopCard(cardView: cardView) ? Double(self.dragState.translation.width / 12) : 0))
                        .animation(.interpolatingSpring(stiffness: 120, damping: 120), value: dragState.translation)
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

                                    if drag.translation.width < -self.dragAreaThreshold {
                                        self.cardRemovalTransition = .leadingBottom
                                    }

                                    if drag.translation.width > self.dragAreaThreshold {
                                        self.cardRemovalTransition = .trailingBottom
                                    }
                                })
                                .onEnded({ (value) in
                                    guard case .second(true, let drag?) = value else {
                                        return
                                    }

                                    if drag.translation.width > self.dragAreaThreshold {
                                        // Swipe right = save to favorites.
                                        if let destination = self.cardViews.first?.destination {
                                            self.userDataStore.addFavorite(destination)
                                        }
                                        self.moveCards()
                                    } else if drag.translation.width < -self.dragAreaThreshold {
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

            Spacer()

            // MARK: - FOOTER

            FooterView(showBookingAlert: $showAlert, onBook: {
                if let destination = cardViews.first?.destination {
                    userDataStore.addBooking(destination)
                }
            })
                .opacity(dragState.isDragging ? 0.0 : 1.0)
                .animation(.default, value: dragState.isDragging)
        }
        .task {
            await destinationStore.load()
            seedCardsIfNeeded()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("SUCCESS"),
                message: Text("Wishing a lovely and most precious of the times together for the amazing couple."),
                dismissButton: .default(Text("Happy HoneyMoon!"))
            )
        }
        .sheet(item: $detailDestination) { destination in
            DestinationDetailView(destination: destination)
                .environmentObject(userDataStore)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DestinationStore())
        .environmentObject(UserDataStore())
}
