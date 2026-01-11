//
//  WelcomeView.swift
//  ExpenseTrackingApp
//
//  Created by Qingtian Chen on 1/11/26.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var oauthService = GoogleOAuthService()
    @State private var isAuthorizing = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("Welcome to Expense Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Track expenses with data stored in your Google Drive.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button {
                connectGoogle()
            } label: {
                if isAuthorizing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text("Connect Google")
                        .fontWeight(.semibold)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isAuthorizing)

            Button("Learn More") {
            }
            .buttonStyle(.bordered)

            Spacer()

            Text("Your data stays in your Google Drive.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, 24)
        }
        .padding()
    }

    private func connectGoogle() {
        errorMessage = nil
        isAuthorizing = true

        oauthService.signIn { result in
            DispatchQueue.main.async {
                isAuthorizing = false

                switch result {
                case .success:
                    appState.onboardingStep = .datasetDiscovery
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AppState())
}
