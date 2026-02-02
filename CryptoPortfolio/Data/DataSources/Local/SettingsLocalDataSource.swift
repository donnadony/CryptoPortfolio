//
//  SettingsLocalDataSource.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Protocol

protocol SettingsLocalDataSourceProtocol: Sendable {
    func loadSettings() async throws -> AppSettings
    func saveSettings(_ settings: AppSettings) async throws
    func resetSettings() async throws
}

// MARK: - Implementation

final class SettingsLocalDataSource: SettingsLocalDataSourceProtocol, @unchecked Sendable {
    
    private let localStorage: LocalStorageProtocol
    private let settingsKey = "app_settings"
    
    init(localStorage: LocalStorageProtocol) {
        self.localStorage = localStorage
    }
    
    func loadSettings() async throws -> AppSettings {
        let settings = try await localStorage.fetch(forKey: settingsKey, as: AppSettings.self)
        return settings ?? .default
    }
    
    func saveSettings(_ settings: AppSettings) async throws {
        try await localStorage.save(settings, forKey: settingsKey)
    }
    
    func resetSettings() async throws {
        try await localStorage.save(AppSettings.default, forKey: settingsKey)
    }
}
