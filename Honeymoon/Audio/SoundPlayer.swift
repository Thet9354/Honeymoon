//
//  SoundPlayer.swift
//  Honeymoon
//
//  Lightweight wrapper around AVAudioPlayer for the app's UI sound effects.
//  Players are cached and pre-prepared so playback is latency-free on first tap.
//

import AVFoundation

/// The bundled sound effects, keyed to their resource names.
enum AppSound: String {
    case swipe = "sound-click"
    case booking = "sound-rise"
}

@MainActor
final class SoundPlayer {

    static let shared = SoundPlayer()

    private var players: [String: AVAudioPlayer] = [:]
    private var sessionConfigured = false

    private init() {}

    /// Plays a sound effect, unless the user has disabled sounds in Settings.
    func play(_ sound: AppSound) {
        // Respect the user's preference. Absent key defaults to on, matching
        // the @AppStorage("soundEnabled") default in SettingsView.
        let enabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        guard enabled else { return }

        configureSessionIfNeeded()

        guard let player = player(for: sound) else { return }
        player.currentTime = 0
        player.play()
    }

    // MARK: - Private

    private func player(for sound: AppSound) -> AVAudioPlayer? {
        if let existing = players[sound.rawValue] { return existing }

        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            return nil
        }

        let player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        players[sound.rawValue] = player
        return player
    }

    private func configureSessionIfNeeded() {
        guard !sessionConfigured else { return }
        sessionConfigured = true
        // .ambient: respects the silent switch and mixes with other audio —
        // the right behaviour for incidental UI sound effects.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}
