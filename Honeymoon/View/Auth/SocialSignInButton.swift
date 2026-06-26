//
//  SocialSignInButton.swift
//  Honeymoon
//

import SwiftUI

enum SocialProvider {
    case apple
    case google

    var label: String {
        switch self {
        case .apple:  "Continue with Apple"
        case .google: "Continue with Google"
        }
    }

    var systemImage: String {
        switch self {
        case .apple:  "apple.logo"
        case .google: "g.circle.fill"
        }
    }

    var foreground: Color {
        switch self {
        case .apple:  .white
        case .google: .primary
        }
    }

    var background: Color {
        switch self {
        case .apple:  .black
        case .google: Color(.secondarySystemBackground)
        }
    }
}

struct SocialSignInButton: View {

    let provider: SocialProvider
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: provider.systemImage)
                    .font(.system(size: 18, weight: .medium))
                Text(provider.label)
                    .font(.system(.headline, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(provider.foreground)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(provider.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.separator), lineWidth: provider == .google ? 1 : 0)
            )
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SocialSignInButton(provider: .apple, action: {})
        SocialSignInButton(provider: .google, action: {})
    }
    .padding()
}
