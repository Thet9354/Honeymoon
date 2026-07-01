//
//  AuthViewModel.swift
//  Honeymoon
//

import Foundation
import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

struct AuthenticatedUser: Identifiable, Equatable {
    let id: String
    let email: String?
    let displayName: String?
    let photoURL: URL?
    /// True for an anonymous "guest" session (browse-before-sign-in).
    var isAnonymous: Bool = false
}

enum AuthError: LocalizedError {
    case missingClientID
    case missingPresenter
    case appleTokenUnavailable
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .missingClientID:       "Sign in is not configured correctly. Please try again later."
        case .missingPresenter:      "Couldn't present the sign-in screen. Please try again."
        case .appleTokenUnavailable: "Apple sign in didn't return a valid token. Please try again."
        case .unknown(let msg):      msg
        }
    }
}

@MainActor
final class AuthViewModel: NSObject, ObservableObject {

    @Published private(set) var currentUser: AuthenticatedUser?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var isAuthenticated: Bool { currentUser != nil }
    /// A guest is signed in anonymously — they can use the app, but should be
    /// nudged to create an account to keep their data across devices.
    var isGuest: Bool { currentUser?.isAnonymous ?? false }

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    // Sign in with Apple state
    private var currentNonce: String?
    private var appleContinuation: CheckedContinuation<Void, Error>?

    /// Designated init. Pass a `currentUser` for SwiftUI previews/tests; in that
    /// case (or when Firebase isn't configured) no live auth listener is attached.
    init(currentUser: AuthenticatedUser? = nil) {
        self.currentUser = currentUser
        super.init()

        guard currentUser == nil, FirebaseApp.app() != nil else { return }

        // Reflect the already-signed-in user immediately on launch.
        if let user = Auth.auth().currentUser {
            self.currentUser = Self.mapUser(user)
        }
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user.map(Self.mapUser)
            }
        }

        // Browse-before-sign-in: ensure there's always a (guest) session so the
        // user reaches the app immediately instead of an auth wall.
        Task { [weak self] in await self?.ensureSignedIn() }
    }

    /// Signs in anonymously when no session exists. If the Anonymous provider is
    /// disabled in Firebase, this fails quietly — the app still works (browsing),
    /// just without persistence until the user signs in.
    func ensureSignedIn() async {
        guard FirebaseApp.app() != nil, Auth.auth().currentUser == nil else { return }
        try? await Auth.auth().signInAnonymously()
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Email / Password

    func signIn(email: String, password: String) async {
        await run {
            try await Auth.auth().signIn(withEmail: email, password: password)
        }
    }

    func signUp(email: String, password: String, displayName: String) async {
        let trimmedName = displayName.trimmingCharacters(in: .whitespaces)
        await run {
            // Upgrade the guest account in place when possible, so favorites,
            // matches, and plans created as a guest carry over.
            let user: User
            if let current = Auth.auth().currentUser, current.isAnonymous {
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                user = try await current.link(with: credential).user
            } else {
                user = try await Auth.auth().createUser(withEmail: email, password: password).user
            }
            if !trimmedName.isEmpty {
                let change = user.createProfileChangeRequest()
                change.displayName = trimmedName
                try? await change.commitChanges()
            }
            try? await user.sendEmailVerification()
            await self.upsertUserDoc(user, displayName: trimmedName)
            self.currentUser = Self.mapUser(user)
        }
    }

    /// Upgrades an anonymous guest by linking the credential (preserving the uid
    /// and all their data); falls back to a normal sign-in if that credential is
    /// already attached to another account.
    @discardableResult
    private func linkOrSignIn(with credential: AuthCredential) async throws -> AuthDataResult {
        if let user = Auth.auth().currentUser, user.isAnonymous {
            do {
                return try await user.link(with: credential)
            } catch {
                let updated = (error as NSError).userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential
                return try await Auth.auth().signIn(with: updated ?? credential)
            }
        }
        return try await Auth.auth().signIn(with: credential)
    }

    func sendPasswordReset(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            return true
        } catch {
            errorMessage = Self.message(for: error)
            return false
        }
    }

    // MARK: - Google

    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = AuthError.missingClientID.errorDescription
            return
        }
        guard let presenter = Self.rootViewController() else {
            errorMessage = AuthError.missingPresenter.errorDescription
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        await run {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.appleTokenUnavailable
            }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            let authResult = try await self.linkOrSignIn(with: credential)
            await self.upsertUserDoc(authResult.user, displayName: authResult.user.displayName)
        } isCancellation: { error in
            (error as NSError).code == GIDSignInError.canceled.rawValue
        }
    }

    // MARK: - Apple

    func signInWithApple() async {
        let nonce = Self.randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self

        await run {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                self.appleContinuation = continuation
                controller.performRequests()
            }
        } isCancellation: { error in
            (error as? ASAuthorizationError)?.code == .canceled
        }
    }

    // MARK: - Session

    func signOut() {
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        errorMessage = nil
        // Drop back to a guest session rather than an auth wall.
        Task { await ensureSignedIn() }
    }

    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let db = Firestore.firestore()
            let uid = user.uid
            // Clean up couple membership so a partner isn't left linked to a ghost,
            // and retire any invite this user's couple still has outstanding.
            if let userSnap = try? await db.collection("users").document(uid).getDocument(),
               let coupleId = userSnap.get("coupleId") as? String {
                if let coupleSnap = try? await db.collection("couples").document(coupleId).getDocument(),
                   let code = coupleSnap.get("inviteCode") as? String {
                    try? await db.collection("invites").document(code).delete()
                }
                try? await db.collection("couples").document(coupleId)
                    .updateData(["members": FieldValue.arrayRemove([uid])])
            }
            try? await db.collection("users").document(uid).delete()
            try await user.delete()
            // The auth state listener clears currentUser; return to a guest session.
            await ensureSignedIn()
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Helpers

    /// Runs an auth operation with shared loading/error handling.
    /// `isCancellation` lets a provider mark user-cancelled errors so they don't surface as failures.
    private func run(
        _ operation: @escaping () async throws -> Void,
        isCancellation: @escaping (Error) -> Bool = { _ in false }
    ) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await operation()
        } catch {
            if !isCancellation(error) {
                errorMessage = Self.message(for: error)
            }
        }
    }

    private func upsertUserDoc(_ user: User, displayName: String?) async {
        let ref = Firestore.firestore().collection("users").document(user.uid)
        var data: [String: Any] = [
            "email": user.email ?? "",
            "displayName": displayName ?? user.displayName ?? "",
            "updatedAt": FieldValue.serverTimestamp()
        ]
        let snapshot = try? await ref.getDocument()
        if snapshot?.exists != true {
            data["createdAt"] = FieldValue.serverTimestamp()
        }
        try? await ref.setData(data, merge: true)
    }

    private static func mapUser(_ user: User) -> AuthenticatedUser {
        AuthenticatedUser(
            id: user.uid,
            email: user.email,
            displayName: user.displayName,
            photoURL: user.photoURL,
            isAnonymous: user.isAnonymous
        )
    }

    private static func rootViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
        return scene?.keyWindow?.rootViewController
    }

    private static func message(for error: Error) -> String {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain else {
            return error.localizedDescription
        }
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue,
             AuthErrorCode.invalidCredential.rawValue:
            return "The email or password is incorrect."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account exists with that email."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password must be at least 6 characters."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "That email is already registered."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Please enter a valid email address."
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection and try again."
        case AuthErrorCode.requiresRecentLogin.rawValue:
            return "Please sign in again before making this change."
        default:
            return error.localizedDescription
        }
    }

    // MARK: - Nonce (Sign in with Apple)

    private static func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var random: UInt8 = 0
            let status = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if status != errSecSuccess { continue }
            if random < charset.count {
                result.append(charset[Int(random) % charset.count])
                remaining -= 1
            }
        }
        return result
    }

    private static func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Sign in with Apple delegate

extension AuthViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        Task { @MainActor in
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let nonce = currentNonce,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8)
            else {
                finishApple(throwing: AuthError.appleTokenUnavailable)
                return
            }

            do {
                let firebaseCredential = OAuthProvider.appleCredential(
                    withIDToken: idToken,
                    rawNonce: nonce,
                    fullName: credential.fullName
                )
                let result = try await linkOrSignIn(with: firebaseCredential)

                let appleName = [credential.fullName?.givenName, credential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                if !appleName.isEmpty, result.user.displayName?.isEmpty != false {
                    let change = result.user.createProfileChangeRequest()
                    change.displayName = appleName
                    try? await change.commitChanges()
                }
                await upsertUserDoc(
                    result.user,
                    displayName: result.user.displayName ?? (appleName.isEmpty ? nil : appleName)
                )
                finishApple(throwing: nil)
            } catch {
                finishApple(throwing: error)
            }
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Task { @MainActor in
            finishApple(throwing: error)
        }
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        Self.rootViewController()?.view.window ?? ASPresentationAnchor()
    }

    private func finishApple(throwing error: Error?) {
        currentNonce = nil
        if let error {
            appleContinuation?.resume(throwing: error)
        } else {
            appleContinuation?.resume()
        }
        appleContinuation = nil
    }
}
