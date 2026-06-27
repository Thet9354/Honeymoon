//
//  MatchCelebrationView.swift
//  Honeymoon
//
//  P4: the "It's a Match!" moment shown when both partners have liked the same
//  destination.
//

import SwiftUI

struct MatchCelebrationView: View {

    let match: CoupleMatch
    var onDismiss: () -> Void
    /// Primary action: start planning this matched destination together.
    var onPlan: () -> Void = {}

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.pink)
                    .scaleEffect(appeared ? 1 : 0.4)
                    .opacity(appeared ? 1 : 0)

                Text("It's a Match!")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("You both love")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))

                Image(match.image)
                    .resizable().scaledToFill()
                    .frame(width: 260, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        VStack {
                            Spacer()
                            Text(match.place.uppercased())
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white)
                                .shadow(radius: 3)
                                .padding(.bottom, 10)
                        }
                    )

                Text("\(match.place), \(match.country)")
                    .font(.headline)
                    .foregroundStyle(.white)

                Button(action: onPlan) {
                    Text("Plan \(match.place) together")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .background(Color.pink, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.white)
                .padding(.horizontal, 40)
                .padding(.top, 8)

                Button(action: onDismiss) {
                    Text("Keep swiping")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(.top, 2)
            }
            .padding(28)
            .scaleEffect(appeared ? 1 : 0.85)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { appeared = true }
        }
    }
}

#Preview {
    MatchCelebrationView(
        match: CoupleMatch(id: "veligandu-maldives", place: "Veligandu", country: "Maldives", image: "photo-veligandu-island-maldives"),
        onDismiss: {}
    )
}
