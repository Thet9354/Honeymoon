//
//  OnboardingPage.swift
//  Honeymoon
//

import SwiftUI

struct OnboardingPage: View {

    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: systemImage)                .font(.system(size: 120, weight: .light))
                .foregroundStyle(Color.pink)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)

            VStack(spacing: 16) {
                Text(title)
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.pink)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    OnboardingPage(
        systemImage: "heart.circle.fill",
        title: "Find your dream honeymoon",
        subtitle: "Swipe through hand-picked destinations from around the world."
    )
}
