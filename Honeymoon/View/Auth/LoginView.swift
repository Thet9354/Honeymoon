//
//  LoginView.swift
//  Honeymoon
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject private var authViewModel: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                socialButtons

                divider

                emailForm

                footer
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sign in failed",
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
            Image("logo-honeymoon-pink")
                .resizable()
                .scaledToFit()
                .frame(height: 36)
                .padding(.top, 12)

            Text("Welcome back")
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(Color.pink)

            Text("Sign in to keep your favorites in sync.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 12)
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
            Text("or")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
            Rectangle().fill(Color(.separator)).frame(height: 1)
        }
    }

    private var emailForm: some View {
        VStack(spacing: 16) {
            AuthFormField(
                systemImage: "envelope",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )

            AuthFormField(
                systemImage: "lock",
                placeholder: "Password",
                text: $password,
                isSecure: true,
                textContentType: .password
            )

            NavigationLink("Forgot password?") {
                ForgotPasswordView()
            }
            .font(.footnote)
            .foregroundStyle(Color.pink)
            .frame(maxWidth: .infinity, alignment: .trailing)

            Button {
                Task { await authViewModel.signIn(email: email, password: password) }
            } label: {
                Group {
                    if authViewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign In")
                    }
                }
                .modifier(ButtonModifier())
            }
            .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
        }
    }

    private var footer: some View {
        HStack(spacing: 4) {
            Text("New here?")
                .foregroundStyle(.secondary)
            NavigationLink("Create an account") {
                SignUpView()
            }
            .foregroundStyle(Color.pink)
            .fontWeight(.semibold)
        }
        .font(.footnote)
        .padding(.top, 8)
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
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
