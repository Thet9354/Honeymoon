//
//  HoneymoonApp.swift
//  Honeymoon
//
//  Created by Phoon Thet Pine on 31/10/23.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct HoneymoonApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    @StateObject private var authViewModel = AuthViewModel()
    // Destinations load from the Firestore `destinations` collection, with the
    // bundled catalog as the offline / not-yet-seeded fallback.
    @StateObject private var destinationStore = DestinationStore(repository: FirestoreDestinationRepository())
    @StateObject private var userDataStore = UserDataStore()
    @StateObject private var preferenceStore = PreferenceStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(destinationStore)
                .environmentObject(userDataStore)
                .environmentObject(preferenceStore)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
