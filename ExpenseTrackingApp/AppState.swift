//
//  AppState.swift
//  ExpenseTrackingApp
//
//  Created by Qingtian Chen on 1/11/26.
//

import Foundation

enum OnboardingStep {
    case welcome
    case datasetDiscovery
    case completed
}

final class AppState: ObservableObject {
    @Published var onboardingStep: OnboardingStep = .welcome
}
