//
//  DatasetDiscoveryView.swift
//  ExpenseTrackingApp
//
//  Created by Qingtian Chen on 1/11/26.
//

import SwiftUI

struct DatasetDiscoveryView: View {
    @EnvironmentObject private var appState: AppState
    @State private var service = DatasetDiscoveryService()
    @State private var isLoading = true
    @State private var isCreating = false
    @State private var errorMessage: String?
    @State private var discoveryState: DiscoveryState = .searching
    @State private var showReplaceAlert = false

    private let creationSteps: [String] = [
        "Create Drive folders",
        "Create spreadsheet tabs",
        "Write Settings metadata",
        "Seed default categories"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Find Your Dataset")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("We’ll look for existing Expense Tracker data in your Google Drive.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                content

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
        .task {
            await discoverDataset()
        }
        .alert("Replace existing dataset?", isPresented: $showReplaceAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Replace", role: .destructive) {
                Task { await createDataset() }
            }
        } message: {
            Text("Creating a new dataset will replace the current dataset selection stored on this device.")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch discoveryState {
        case .searching:
            VStack(spacing: 12) {
                ProgressView("Searching for datasets...")
                Text("Looking for PersonalFinanceApps/ExpenseTracker")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        case .found(let summary):
            datasetSummaryView(summary)
        case .notFound:
            notFoundView
        case .creating(let currentStep):
            createDatasetView(currentStep: currentStep)
        case .created(let summary):
            createdView(summary)
        }
    }

    private func datasetSummaryView(_ summary: DatasetSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("We found your dataset")
                .font(.headline)

            summaryCard(summary)

            Button("Use This Dataset") {
                appState.datasetSummary = summary
                appState.onboardingStep = .completed
            }
            .buttonStyle(.borderedProminent)

            Button("Create New Dataset Instead") {
                showReplaceAlert = true
            }
            .buttonStyle(.bordered)
            .disabled(isCreating)
        }
    }

    private var notFoundView: some View {
        VStack(spacing: 12) {
            Text("No dataset found")
                .font(.headline)

            Text("We couldn’t find an existing Expense Tracker dataset. You can create a new one now.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Create New Dataset") {
                Task { await createDataset() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isCreating)
        }
    }

    private func createDatasetView(currentStep: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Creating dataset...")
                .font(.headline)

            ForEach(creationSteps.indices, id: \.self) { index in
                HStack {
                    Image(systemName: index < currentStep ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(index < currentStep ? .green : .secondary)
                    Text(creationSteps[index])
                        .font(.subheadline)
                }
            }

            ProgressView(value: Double(currentStep), total: Double(creationSteps.count))
        }
    }

    private func createdView(_ summary: DatasetSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dataset ready")
                .font(.headline)

            summaryCard(summary)

            Button("Start Using App") {
                appState.datasetSummary = summary
                appState.onboardingStep = .completed
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func summaryCard(_ summary: DatasetSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(summary.name)
                .font(.title3)
                .fontWeight(.semibold)

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
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func discoverDataset() async {
        guard isLoading else { return }
        isLoading = false
        errorMessage = nil

        if let summary = await service.discoverDataset() {
            discoveryState = .found(summary)
        } else {
            discoveryState = .notFound
        }
    }

    private func createDataset() async {
        guard !isCreating else { return }
        isCreating = true
        errorMessage = nil

        for index in 0..<creationSteps.count {
            discoveryState = .creating(currentStep: index)
            try? await Task.sleep(nanoseconds: 250_000_000)
        }

        let summary = await service.createDataset()
        discoveryState = .created(summary)
        isCreating = false
    }
}

#Preview {
    DatasetDiscoveryView()
        .environmentObject(AppState())
}

private enum DiscoveryState: Equatable {
    case searching
    case found(DatasetSummary)
    case notFound
    case creating(currentStep: Int)
    case created(DatasetSummary)
}
