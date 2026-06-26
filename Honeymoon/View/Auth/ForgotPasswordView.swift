//
//  ForgotPasswordView.swift
//  Honeymoon
//

import SwiftUI

struct ForgotPasswordView: View {

    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var didSend: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                AuthFormField(
                    systemImage: "envelope",
                    placeholder: "Email",
                    text: $email,
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress
                )

                sendButton

                if didSend {
                    Text("Check your inbox for password reset instructions.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemBackground))
        .navigationTitle("Reset password")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Couldn't send reset email",
               isPresented: errorBinding,
               presenting: authViewModel.errorMessage) { _ in
            Button("OK", role: .cancel) { authViewModel.clearError() }
        } message: { message in
            Text(message)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "key.horizontal.fill")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(Color.pink)
                .symbolRenderingMode(.hierarchical)
            Text("Forgot password?")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(Color.pink)
            Text("Enter your email and we'll send you a link to reset it.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var sendButton: some View {
        Button {
            Task {
                let success = await authViewModel.sendPasswordReset(email: email)
                if success { didSend = true }
            }
        } label: {
            Group {
                if authViewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Send reset link")
                }
            }
            .modifier(ButtonModifier())
        }
        .disabled(authViewModel.isLoading || email.isEmpty)
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { authViewModel.errorMessage != nil },
            set: { if !$0 { authViewModel.clearError() } }
        )
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
            .environmentObject(AuthViewModel())
    }
}
