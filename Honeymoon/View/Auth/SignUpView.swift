//
//  SignUpView.swift
//  Honeymoon
//

import SwiftUI

struct SignUpView: View {

    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var acceptedTerms: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                socialButtons

                divider

                emailForm

                termsToggle

                createButton
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemBackground))
        .navigationTitle("Create account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sign up failed",
               isPresented: errorBinding,
               presenting: authViewModel.errorMessage) { _ in
            Button("OK", role: .cancel) { authViewModel.clearError() }
        } message: { message in
            Text(message)
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(Color.pink)
                .symbolRenderingMode(.hierarchical)

            Text("Plan trips, together")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(Color.pink)

            Text("Create your account to save the places you love.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var socialButtons: some View {
        VStack(spacing: 12) {
            SocialSignInButton(provider: .apple) {
                Task { await authViewModel.signInWithApple() }
            }
            SocialSignInButton(provider: .google) {
                Task { await authViewModel.signInWithGoogle() }
            }
        }
    }

    private var divider: some View {
        HStack {
            Rectangle().fill(Color(.separator)).frame(height: 1)
            Text("or with email")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
            Rectangle().fill(Color(.separator)).frame(height: 1)
        }
    }

    private var emailForm: some View {
        VStack(spacing: 16) {
            AuthFormField(
                systemImage: "person",
                placeholder: "Your name",
                text: $name,
                textContentType: .name,
                autocapitalization: .words
            )
            AuthFormField(
                systemImage: "envelope",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
            AuthFormField(
                systemImage: "lock",
                placeholder: "Password (min 6 characters)",
                text: $password,
                isSecure: true,
                textContentType: .newPassword
            )
        }
    }

    private var termsToggle: some View {
        Toggle(isOn: $acceptedTerms) {
            Text("I agree to the Terms of Service and Privacy Policy.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .tint(Color.pink)
    }

    private var createButton: some View {
        Button {
            Task {
                await authViewModel.signUp(email: email, password: password, displayName: name)
            }
        } label: {
            Group {
                if authViewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Create Account")
                }
            }
            .modifier(ButtonModifier())
        }
        .disabled(authViewModel.isLoading || !canSubmit)
    }

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !email.isEmpty
            && password.count >= 6
            && acceptedTerms
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
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
