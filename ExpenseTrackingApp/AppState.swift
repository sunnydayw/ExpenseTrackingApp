//
//  AppState.swift
//  ExpenseTrackingApp
//
//  Created by Qingtian Chen on 1/11/26.
//

import Foundation
internal import Combine

enum OnboardingStep {
    case welcome
    case datasetDiscovery
    case completed
}

final class AppState: ObservableObject {
    @Published var onboardingStep: OnboardingStep = .welcome
    @Published var datasetSummary: DatasetSummary?

    private let datasetStore: DatasetStore

    init(datasetStore: DatasetStore = DatasetStore()) {
        self.datasetStore = datasetStore
        if let summary = datasetStore.loadSummary() {
            datasetSummary = summary
            onboardingStep = .completed
        }
    }
}
