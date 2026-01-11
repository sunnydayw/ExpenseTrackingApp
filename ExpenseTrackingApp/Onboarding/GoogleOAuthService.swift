//
//  GoogleOAuthService.swift
//  ExpenseTrackingApp
//
//  Created by Qingtian Chen on 1/11/26.
//

import AuthenticationServices
import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

final class GoogleOAuthService: NSObject {
    struct Configuration {
        let clientID: String
        let redirectURI: String
        let scopes: [String]

        var redirectURIScheme: String {
            URL(string: redirectURI)?.scheme ?? ""
        }

        static let `default` = Configuration(
            clientID: "YOUR_GOOGLE_CLIENT_ID",
            redirectURI: "com.googleusercontent.apps.YOUR_GOOGLE_CLIENT_ID:/oauthredirect",
            scopes: [
                "https://www.googleapis.com/auth/drive.file",
                "https://www.googleapis.com/auth/spreadsheets"
            ]
        )
    }

    enum AuthError: LocalizedError {
        case cancelled
        case invalidCallback
        case missingAuthorizationCode
        case stateMismatch

        var errorDescription: String? {
            switch self {
            case .cancelled:
                return "Sign in was cancelled. Please try again."
            case .invalidCallback:
                return "Unable to complete sign-in."
            case .missingAuthorizationCode:
                return "Authorization code was missing from the response."
            case .stateMismatch:
                return "Sign-in verification failed. Please try again."
            }
        }
    }

    private let configuration: Configuration
    private var session: ASWebAuthenticationSession?
    private var currentState: String?

    init(configuration: Configuration = .default) {
        self.configuration = configuration
        super.init()
    }

    func signIn(completion: @escaping (Result<String, Error>) -> Void) {
        let state = UUID().uuidString
        currentState = state

        guard let authURL = authorizationURL(state: state) else {
            completion(.failure(AuthError.invalidCallback))
            return
        }

        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: configuration.redirectURIScheme
        ) { [weak self] callbackURL, error in
            if let error = error as? ASWebAuthenticationSessionError,
               error.code == .canceledLogin {
                completion(.failure(AuthError.cancelled))
                return
            }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let callbackURL = callbackURL,
                  let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                  let items = components.queryItems else {
                completion(.failure(AuthError.invalidCallback))
                return
            }

            let code = items.first(where: { $0.name == "code" })?.value
            let returnedState = items.first(where: { $0.name == "state" })?.value

            guard returnedState == self?.currentState else {
                completion(.failure(AuthError.stateMismatch))
                return
            }

            guard let code else {
                completion(.failure(AuthError.missingAuthorizationCode))
                return
            }

            completion(.success(code))
        }

        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        self.session = session
        session.start()
    }

    private func authorizationURL(state: String) -> URL? {
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.clientID),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.scopes.joined(separator: " ")),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "include_granted_scopes", value: "true"),
            URLQueryItem(name: "prompt", value: "consent"),
            URLQueryItem(name: "state", value: state)
        ]
        return components?.url
    }
}

extension GoogleOAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if canImport(UIKit)
        // iOS/tvOS: try to find the active key window
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            if let keyWindow = windowScene.keyWindow {
                return keyWindow
            }
            if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return window
            }
            if let anyWindow = windowScene.windows.first {
                return anyWindow
            }
        }
        return UIWindow()
        #elseif canImport(AppKit)
        // macOS: return the key window or a new window
        return NSApplication.shared.keyWindow ?? NSWindow()
        #else
        return ASPresentationAnchor()
        #endif
    }
}
