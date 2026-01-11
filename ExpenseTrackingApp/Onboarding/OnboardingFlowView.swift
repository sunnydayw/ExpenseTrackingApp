//
//  OnboardingFlowView.swift
//  ExpenseTrackingApp
//
//  Created by Qingtian Chen on 1/11/26.
//

import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        switch appState.onboardingStep {
        case .welcome:
            WelcomeView()
        case .datasetDiscovery:
            DatasetDiscoveryView()
        case .completed:
            ContentView()
        }
    }
}

#Preview {
    OnboardingFlowView()
        .environmentObject(AppState())
}
