//
//  CardView.swift
//  Honeymoon
//
//  Created by Phoon Thet Pine on 31/10/23.
//

import SwiftUI

struct CardView: View, Identifiable {

    // MARK: - PROPERTIES

    let id = UUID()
    var destination: Destination
    /// Optional one-line "why this was picked for you" rationale (P2 preferences).
    var reason: String? = nil

    // MARK: - BODY

    /// The deck's card shape. The original catalogue photos are portrait
    /// 1200×1920 (0.625); pinning every card to that ratio and filling it keeps
    /// the deck uniform no matter each source photo's dimensions. The full,
    /// uncropped image is still used on the detail screen.
    private let cardAspectRatio: CGFloat = 1200.0 / 1920.0

    var body: some View {
        Color.clear
            .aspectRatio(cardAspectRatio, contentMode: .fit)
            .overlay {
                Image(destination.image)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(alignment: .bottom) {
                VStack(alignment: .center, spacing: 12) {
                    Text(destination.place.uppercased())
                        .foregroundColor(Color.white)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .shadow(radius: 1)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 4)
                        .overlay(
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 1),
                            alignment: .bottom
                        )

                    Text(destination.country.uppercased())
                        .foregroundColor(Color.black)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .frame(minWidth: 85)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )

                    if let reason {
                        Text(reason)
                            .foregroundColor(.white)
                            .font(.caption2.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.top, 2)
                    }
                }
                .frame(minWidth: 280)
                .padding(.bottom, 50)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(destination.place), \(destination.country)")
            .accessibilityHint("Swipe right to like, swipe left to pass")
            .accessibilityAddTraits(.isImage)
    }
}

// MARK: - PREVIEW

#Preview {
    CardView(destination: honeymoonData[0])
        .previewLayout(.fixed(width: 375, height: 600))
}
