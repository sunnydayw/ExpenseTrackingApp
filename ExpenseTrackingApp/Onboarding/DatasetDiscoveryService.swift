//
//  DatasetDiscoveryService.swift
//  ExpenseTrackingApp
//
//  Created by Qingtian Chen on 1/11/26.
//

import Foundation

struct DatasetSummary: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let rootFolder: String
    let spreadsheetName: String
    let lastModified: Date
}

struct DatasetSettings: Codable, Equatable {
    let datasetId: UUID
    let schemaVersion: Int
    let rootFolderId: String
    let receiptsFolderId: String
    let dataSpreadsheetId: String
    let createdAt: Date
    let lastModifiedAt: Date
}

final class DatasetStore {
    private let userDefaults: UserDefaults
    private let summaryKey = "dataset.summary"
    private let settingsKey = "dataset.settings"
    private let categoriesKey = "dataset.defaultCategories"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadSummary() -> DatasetSummary? {
        guard let data = userDefaults.data(forKey: summaryKey) else {
            return nil
        }
        return try? JSONDecoder().decode(DatasetSummary.self, from: data)
    }

    func saveSummary(_ summary: DatasetSummary) {
        guard let data = try? JSONEncoder().encode(summary) else {
            return
        }
        userDefaults.set(data, forKey: summaryKey)
    }

    func loadSettings() -> DatasetSettings? {
        guard let data = userDefaults.data(forKey: settingsKey) else {
            return nil
        }
        return try? JSONDecoder().decode(DatasetSettings.self, from: data)
    }

    func saveSettings(_ settings: DatasetSettings) {
        guard let data = try? JSONEncoder().encode(settings) else {
            return
        }
        userDefaults.set(data, forKey: settingsKey)
    }

    func saveDefaultCategories(_ categories: [String]) {
        userDefaults.set(categories, forKey: categoriesKey)
    }

    func clearDataset() {
        userDefaults.removeObject(forKey: summaryKey)
        userDefaults.removeObject(forKey: settingsKey)
        userDefaults.removeObject(forKey: categoriesKey)
    }
}

final class DatasetDiscoveryService {
    private let store: DatasetStore

    init(store: DatasetStore = DatasetStore()) {
        self.store = store
    }

    func discoverDataset() async -> DatasetSummary? {
        try? await Task.sleep(nanoseconds: 300_000_000)
        return store.loadSummary()
    }

    func createDataset() async -> DatasetSummary {
        try? await Task.sleep(nanoseconds: 300_000_000)

        let now = Date()
        let datasetId = UUID()
        let summary = DatasetSummary(
            id: datasetId,
            name: "ExpenseTracker",
            rootFolder: "PersonalFinanceApps/ExpenseTracker",
            spreadsheetName: "ExpenseTracker.gsheet",
            lastModified: now
        )

        let settings = DatasetSettings(
            datasetId: datasetId,
            schemaVersion: 1,
            rootFolderId: UUID().uuidString,
            receiptsFolderId: UUID().uuidString,
            dataSpreadsheetId: UUID().uuidString,
            createdAt: now,
            lastModifiedAt: now
        )

        store.saveSummary(summary)
        store.saveSettings(settings)
        store.saveDefaultCategories(DatasetSeed.defaultCategories)
        return summary
    }
}

enum DatasetSeed {
    static let defaultCategories: [String] = [
        "Groceries",
        "Dining",
        "Rent",
        "Utilities",
        "Transport",
        "Entertainment",
        "Health",
        "Shopping",
        "Salary",
        "Interest"
    ]
}
