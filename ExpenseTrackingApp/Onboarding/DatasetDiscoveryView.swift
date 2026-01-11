//
//  DatasetDiscoveryView.swift
//  ExpenseTrackingApp
//
//  Created by Qingtian Chen on 1/11/26.
//

import SwiftUI

struct DatasetDiscoveryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Find Your Dataset")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("We’ll look for existing Expense Tracker data in your Google Drive next.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("Dataset discovery is coming in US-01.02.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    DatasetDiscoveryView()
}
