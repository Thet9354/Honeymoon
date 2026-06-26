//
//  PreferenceStore.swift
//  Honeymoon
//
//  Persists the user's TravelPreferences locally (UserDefaults) and ranks the
//  destination deck by them. Local storage is deliberate: the onboarding quiz
//  runs before sign-in, and ranking happens client-side.
//

import Foundation
import Combine

@MainActor
final class PreferenceStore: ObservableObject {

    @Published var preferences: TravelPreferences {
        didSet { save() }
    }

    /// True once the user has completed (or explicitly skipped) the quiz.
    @Published var hasCompletedQuiz: Bool

    private let defaults: UserDefaults
    private let preferencesKey = "travelPreferences"
    private let completedKey = "hasCompletedPreferenceQuiz"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hasCompletedQuiz = defaults.bool(forKey: completedKey)
        if let data = defaults.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(TravelPreferences.self, from: data) {
            self.preferences = decoded
        } else {
            self.preferences = TravelPreferences()
        }
    }

    /// Ranks destinations by the stored preferences.
    func ranked(_ destinations: [Destination]) -> [Destination] {
        preferences.ranked(destinations)
    }

    /// Marks the quiz as done (whether saved with choices or skipped).
    func markQuizCompleted() {
        hasCompletedQuiz = true
        defaults.set(true, forKey: completedKey)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(preferences) {
            defaults.set(data, forKey: preferencesKey)
        }
    }
}
