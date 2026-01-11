//
//  RootView.swift
//  ExpenseTrackingApp
//
//  Created by Qingtian Chen on 1/11/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if appState.onboardingStep == .completed {
            ContentView()
        } else {
            OnboardingFlowView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
