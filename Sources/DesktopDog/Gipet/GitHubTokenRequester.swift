// Gipet — GitHub OAuth web flow (mirrors Git Streaks' `GitHubTokenRequester`
// + `AppDeeplinkHandler`).
//
// Flow, identical in shape to Git Streaks:
//   1. Open the browser to  https://github.com/login/oauth/authorize
//      with redirect_uri = gipet://callback  (Git Streaks used githubstreak://).
//   2. GitHub redirects back to the app via the custom URL scheme with `?code=`.
//   3. Exchange the code at  https://github.com/login/oauth/access_token
//      for an access token, then persist it.
//
// ⚠️ Fill in your own OAuth app credentials below. Create one at
//    https://github.com/settings/developers  →  "New OAuth App"
//    Authorization callback URL:  gipet://callback
//    Then paste Client ID / Client Secret here.

import Foundation
import AppKit
import AuthenticationServices

enum GipetGitHub {
    static let clientID     = GipetSecrets.githubClientID
    static let clientSecret = GipetSecrets.githubClientSecret
    static let scope        = "read:user"
    static let callbackScheme = "gipet"
    static let redirectURI  = "gipet://callback"

    static var isConfigured: Bool {
        !clientID.hasPrefix("YOUR_") && !clientSecret.hasPrefix("YOUR_")
    }
}

/// Persists the GitHub access token + cached login in the Keychain (token)
/// and UserDefaults (non-sensitive username/login cache).
final class TokenStore {
    static let shared = TokenStore()
    private let tokenKey = "githubToken"
    private let loginKey = "Gipet.githubLogin"
    private let userKey  = "Gipet.githubUsername"

    /// OAuth / Personal Access Token — stored in Keychain.
    var token: String? {
        get { KeychainHelper.load(for: tokenKey) }
        set {
            if let v = newValue { KeychainHelper.save(v, for: tokenKey) }
            else { KeychainHelper.delete(for: tokenKey) }
            APIClient.shared.accessToken = newValue
        }
    }
    /// Manually entered username — lets us load public contributions with no token.
    var username: String? {
        get { UserDefaults.standard.string(forKey: userKey) }
        set { UserDefaults.standard.set(newValue?.trimmingCharacters(in: .whitespacesAndNewlines), forKey: userKey) }
    }
    var cachedLogin: String? {
        get { UserDefaults.standard.string(forKey: loginKey) }
        set { UserDefaults.standard.set(newValue, forKey: loginKey) }
    }

    var hasToken: Bool { token?.isEmpty == false }
    var hasUsername: Bool { username?.isEmpty == false }
    var isSignedIn: Bool { hasToken || hasUsername }

    func signOut() {
        token = nil
        username = nil
        cachedLogin = nil
    }

    private init() {
        migrateFromUserDefaults()
        APIClient.shared.accessToken = token
    }

    // One-time migration: move any token stored in UserDefaults (old builds) to Keychain.
    private func migrateFromUserDefaults() {
        let legacyKey = "Gipet.githubToken"
        if let legacy = UserDefaults.standard.string(forKey: legacyKey), !legacy.isEmpty {
            KeychainHelper.save(legacy, for: tokenKey)
            UserDefaults.standard.removeObject(forKey: legacyKey)
        }
    }
}

struct AccessTokenResponse: Decodable {
    let access_token: String?
    let error: String?
    let error_description: String?
}

/// Drives the OAuth web flow using ASWebAuthenticationSession (required by App Review guideline 4.0).
final class GitHubTokenRequester: NSObject {
    static let shared = GitHubTokenRequester()

    private var authSession: ASWebAuthenticationSession?
    private var state: String = ""

    @MainActor
    func signIn() async throws -> String {
        guard GipetGitHub.isConfigured else {
            throw APIError.decode("OAuth not configured — set GipetGitHub.clientID/clientSecret")
        }
        state = "gipet-\(ProcessInfo.processInfo.globallyUniqueString.prefix(12))"

        var comps = URLComponents(string: "https://github.com/login/oauth/authorize")!
        comps.queryItems = [
            URLQueryItem(name: "client_id", value: GipetGitHub.clientID),
            URLQueryItem(name: "redirect_uri", value: GipetGitHub.redirectURI),
            URLQueryItem(name: "scope", value: GipetGitHub.scope),
            URLQueryItem(name: "state", value: state),
        ]
        guard let url = comps.url else { throw APIError.badURL }

        let callbackURL: URL = try await withCheckedThrowingContinuation { cont in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: GipetGitHub.callbackScheme
            ) { [weak self] callbackURL, error in
                self?.authSession = nil
                if let error = error {
                    cont.resume(throwing: error)
                } else if let url = callbackURL {
                    cont.resume(returning: url)
                } else {
                    cont.resume(throwing: APIError.decode("No callback URL received"))
                }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self.authSession = session
            session.start()
        }

        guard let cbComps = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              let code = cbComps.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw APIError.decode("oauth callback missing code")
        }
        let returnedState = cbComps.queryItems?.first(where: { $0.name == "state" })?.value
        if !state.isEmpty, returnedState != state {
            NSLog("[Gipet] oauth state mismatch (expected \(state), got \(returnedState ?? "nil"))")
        }

        return try await exchange(code: code)
    }

    /// Fallback: called by AppDeeplinkHandler if the app is relaunched with a pending callback URL.
    func handleCallback(_ url: URL) {
        NSLog("[Gipet] deeplink callback received: \(url.absoluteString)")
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = comps.queryItems?.first(where: { $0.name == "code" })?.value else {
            NSLog("[Gipet] callback missing code")
            return
        }
        Task { try? await exchange(code: code) }
    }

    @discardableResult
    private func exchange(code: String) async throws -> String {
        guard let url = URL(string: "https://github.com/login/oauth/access_token") else {
            throw APIError.badURL
        }
        let resp = try await APIClient.shared.post(AccessTokenResponse.self, url, form: [
            "client_id": GipetGitHub.clientID,
            "client_secret": GipetGitHub.clientSecret,
            "code": code,
            "redirect_uri": GipetGitHub.redirectURI,
            "state": state,
        ])
        guard let token = resp.access_token, !token.isEmpty else {
            throw APIError.decode(resp.error_description ?? resp.error ?? "no access_token")
        }
        NSLog("[Gipet] token exchange ok")
        TokenStore.shared.token = token
        await MainActor.run {
            GipetViewModel.shared.objectWillChange.send()
            GipetViewModel.shared.refresh()
        }
        return token
    }
}

extension GitHubTokenRequester: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        NSApp.keyWindow ?? NSApp.windows.first ?? NSWindow()
    }
}

/// Handles the `gipet://` custom URL scheme (mirrors `AppDeeplinkHandler`).
final class AppDeeplinkHandler: NSObject {
    static let shared = AppDeeplinkHandler()

    /// Register for GetURL apple events. Call from applicationWillFinishLaunching.
    func register() {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL))
    }

    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent: NSAppleEventDescriptor) {
        guard let str = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: str) else { return }
        if url.scheme == GipetGitHub.callbackScheme {
            GitHubTokenRequester.shared.handleCallback(url)
        }
    }
}
