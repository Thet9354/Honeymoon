//
//  AppearanceMode.swift
//  Honeymoon
//

import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: "System"
        case .light:  "Light"
        case .dark:   "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light:  .light
        case .dark:   .dark
        }
    }
}

extension View {
    /// Applies the user's saved appearance to this view. Needed on sheet roots:
    /// a sheet is presented outside the root's `preferredColorScheme`, so without
    /// this it ignores the setting until the app relaunches.
    func appAppearance() -> some View { modifier(AppAppearanceModifier()) }
}

private struct AppAppearanceModifier: ViewModifier {
    @AppStorage("appearance") private var appearanceRaw = AppearanceMode.system.rawValue

    func body(content: Content) -> some View {
        content.preferredColorScheme((AppearanceMode(rawValue: appearanceRaw) ?? .system).colorScheme)
    }
}
