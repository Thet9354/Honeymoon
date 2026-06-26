//
//  RootView.swift
//  Honeymoon
//

import SwiftUI

struct RootView: View {

    @EnvironmentObject private var authViewModel: AuthViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("appearance") private var appearanceRaw: String = AppearanceMode.system.rawValue

    private var appearance: AppearanceMode {
        AppearanceMode(rawValue: appearanceRaw) ?? .system
    }

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(onComplete: {
                    hasCompletedOnboarding = true
                })
                .transition(.opacity)
            } else if !authViewModel.isAuthenticated {
                AuthView()
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: hasCompletedOnboarding)
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
        .preferredColorScheme(appearance.colorScheme)
    }
}

#Preview("Not onboarded") {
    let _ = UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    return RootView()
        .environmentObject(AuthViewModel())
        .environmentObject(DestinationStore())
        .environmentObject(UserDataStore())
        .environmentObject(PreferenceStore())
        .environmentObject(CoupleStore())
}

#Preview("Onboarded") {
    let _ = UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    return RootView()
        .environmentObject(AuthViewModel(currentUser: AuthenticatedUser(id: "preview", email: nil, displayName: "Preview", photoURL: nil)))
        .environmentObject(DestinationStore())
        .environmentObject(UserDataStore())
        .environmentObject(PreferenceStore())
        .environmentObject(CoupleStore())
}
