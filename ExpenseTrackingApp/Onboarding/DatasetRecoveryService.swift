//
//  DatasetRecoveryService.swift
//  ExpenseTrackingApp
//
//  Created by Qingtian Chen on 1/11/26.
//

import Foundation

enum DatasetRecoveryError: LocalizedError {
    case noDatasetLinked

    var errorDescription: String? {
        switch self {
        case .noDatasetLinked:
            return "No dataset is currently linked to this device."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noDatasetLinked:
            return "Relink a dataset from Drive to continue syncing."
        }
    }
}

final class DatasetRecoveryService {
    private let store: DatasetStore

    init(store: DatasetStore = DatasetStore()) {
        self.store = store
    }

    func syncNow() async throws -> DatasetSummary {
        try? await Task.sleep(nanoseconds: 350_000_000)
        guard let summary = store.loadSummary() else {
            throw DatasetRecoveryError.noDatasetLinked
        }
        return summary
    }

    func relinkDataset() {
        store.clearDataset()
    }
}
