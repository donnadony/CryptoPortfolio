//
//  SettingsRepository.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Repository Protocol

protocol SettingsRepository: Sendable {
    func loadSettings() async throws -> AppSettings
    func saveSettings(_ settings: AppSettings) async throws
    func resetSettings() async throws
}

// MARK: - Implementation

final class SettingsRepositoryImpl: SettingsRepository, @unchecked Sendable {
    
    private let localDataSource: SettingsLocalDataSourceProtocol
    
    init(localDataSource: SettingsLocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }
    
    func loadSettings() async throws -> AppSettings {
        do {
            return try await localDataSource.loadSettings()
        } catch let error as StorageError {
            throw DomainError.from(storageError: error)
        }
    }
    
    func saveSettings(_ settings: AppSettings) async throws {
        do {
            try await localDataSource.saveSettings(settings)
        } catch let error as StorageError {
            throw DomainError.from(storageError: error)
        }
    }
    
    func resetSettings() async throws {
        do {
            try await localDataSource.resetSettings()
        } catch let error as StorageError {
            throw DomainError.from(storageError: error)
        }
    }
}
