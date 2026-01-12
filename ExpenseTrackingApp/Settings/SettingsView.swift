//
//  SettingsView.swift
//  ExpenseTrackingApp
//
//  Created by Qingtian Chen on 1/11/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var isSyncing = false
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    @State private var recoveryService = DatasetRecoveryService()

    var body: some View {
        NavigationStack {
            List {
                datasetSection
                recoverySection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Recovery failed", isPresented: $isShowingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var datasetSection: some View {
        Section("Dataset") {
            if let summary = appState.datasetSummary {
                VStack(alignment: .leading, spacing: 6) {
                    Text(summary.name)
                        .font(.headline)
                    Text("Root folder: \(summary.rootFolder)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Spreadsheet: \(summary.spreadsheetName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Last modified \(summary.lastModified.formatted(date: .abbreviated, time: .shortened))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("No dataset linked yet.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var recoverySection: some View {
        Section("Data & Sync") {
            Button {
                Task {
                    await syncNow()
                }
            } label: {
                HStack {
                    Text("Sync Now")
                    if isSyncing {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            .disabled(isSyncing)

            Button("Relink Dataset") {
                relinkDataset()
            }
            .foregroundStyle(.red)
        }
    }

    private func syncNow() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        do {
            let summary = try await recoveryService.syncNow()
            appState.datasetSummary = summary
        } catch {
            handleRecoveryError(error)
        }
    }

    private func relinkDataset() {
        recoveryService.relinkDataset()
        appState.datasetSummary = nil
        appState.onboardingStep = .datasetDiscovery
        dismiss()
    }

    private func handleRecoveryError(_ error: Error) {
        if let recoveryError = error as? DatasetRecoveryError {
            let message = recoveryError.recoverySuggestion ?? "Try relinking your dataset."
            alertMessage = "\(recoveryError.localizedDescription) \(message)"
        } else {
            alertMessage = "We couldn’t refresh your dataset. Try again or relink to a dataset."
        }
        isShowingAlert = true
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
