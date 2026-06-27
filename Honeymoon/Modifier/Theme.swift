//
//  Theme.swift
//  Honeymoon
//
//  Lightweight design tokens. Centralizes the brand accent and the primary
//  call-to-action style so prominent buttons stay consistent as the app grows —
//  change the look in one place instead of per view.
//

import SwiftUI

enum Theme {
    /// Corner radius used for primary buttons and cards.
    static let cornerRadius: CGFloat = 14
}

extension Color {
    /// The app's brand accent. Aliased to system pink today; if the brand colour
    /// ever changes, update it here and every CTA follows.
    static let brand = Color.pink
}

/// Full-width, filled brand button for primary calls to action.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.brand, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .foregroundStyle(.white)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
