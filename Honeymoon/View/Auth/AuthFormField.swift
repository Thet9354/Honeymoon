//
//  AuthFormField.swift
//  Honeymoon
//

import SwiftUI

struct AuthFormField: View {

    let systemImage: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization = .never

    @State private var isRevealed = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            Group {
                if isSecure && !isRevealed {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled()

            if isSecure {
                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                        .frame(width: 22)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        AuthFormField(systemImage: "envelope", placeholder: "Email", text: .constant("hello@world.com"))
        AuthFormField(systemImage: "lock", placeholder: "Password", text: .constant("secret"), isSecure: true)
    }
    .padding()
}
