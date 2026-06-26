//
//  SettingsView.swift
//  Honeymoon
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @AppStorage("appearance") private var appearanceRaw: String = AppearanceMode.system.rawValue
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true

    @State private var showSignOutConfirmation = false
    @State private var showDeleteAccountConfirmation = false

    private var appearance: Binding<AppearanceMode> {
        Binding(
            get: { AppearanceMode(rawValue: appearanceRaw) ?? .system },
            set: { appearanceRaw = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            List {
                profileSection
                preferencesSection
                legalSection
                supportSection
                aboutSection
                dangerZoneSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .tint(Color.pink)
        }
    }

    // MARK: - Sections

    private var profileSection: some View {
        Section {
            HStack(spacing: 16) {
                avatar
                VStack(alignment: .leading, spacing: 2) {
                    Text(authViewModel.currentUser?.displayName ?? "Guest")
                        .font(.headline)
                    if let email = authViewModel.currentUser?.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color.pink.opacity(0.15))
            Image(systemName: "person.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.pink)
        }
        .frame(width: 48, height: 48)
    }

    private var preferencesSection: some View {
        Section("Preferences") {
            Picker("Appearance", selection: appearance) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }

            Toggle("Sound effects", isOn: $soundEnabled)
        }
    }

    private var legalSection: some View {
        Section("Legal") {
            NavigationLink {
                LegalView(document: .privacyPolicy)
            } label: {
                Label("Privacy Policy", systemImage: "hand.raised")
            }

            NavigationLink {
                LegalView(document: .termsOfService)
            } label: {
                Label("Terms of Service", systemImage: "doc.text")
            }

            NavigationLink {
                AcknowledgementsView()
            } label: {
                Label("Acknowledgements", systemImage: "heart.text.square")
            }
        }
    }

    private var supportSection: some View {
        Section("Support") {
            Button {
                if let url = URL(string: "mailto:thetpine254@gmail.com?subject=Honeymoon%20App%20Support") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("Contact us", systemImage: "envelope")
            }
            .foregroundStyle(.primary)
        }
    }

    private var aboutSection: some View {
        Section("About") {
            LabeledContent("Version", value: appVersion)
            LabeledContent("Build", value: appBuild)
        }
    }

    private var dangerZoneSection: some View {
        Section {
            Button(role: .none) {
                showSignOutConfirmation = true
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .foregroundStyle(Color.pink)
            }

            Button(role: .destructive) {
                showDeleteAccountConfirmation = true
            } label: {
                Label("Delete Account", systemImage: "trash")
            }
        }
        .confirmationDialog(
            "Sign out of Honeymoon?",
            isPresented: $showSignOutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                authViewModel.signOut()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(
            "Delete your account?",
            isPresented: $showDeleteAccountConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                Task {
                    await authViewModel.deleteAccount()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes your account and all saved favorites. This cannot be undone.")
        }
    }

    // MARK: - Bundle info

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel(currentUser: AuthenticatedUser(
            id: "preview",
            email: "thet@example.com",
            displayName: "Thet Pine",
            photoURL: nil
        )))
}
