//
//  SettingsServiceImpl.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

/// Service implementation that uses Repository pattern
final class SettingsServiceImpl: SettingsServiceProtocol, @unchecked Sendable {
    
    private let repository: SettingsRepository
    
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func loadSettings() -> AppSettings {
        do {
            return try runAsyncAndBlock {
                try await self.repository.loadSettings()
            } ?? .default
        } catch {
            return .default
        }
    }
    
    func saveSettings(_ settings: AppSettings) {
        Task {
            try? await repository.saveSettings(settings)
        }
    }
    
    func getCurrentSettings() -> AppSettings {
        loadSettings()
    }
    
    func resetSettings() {
        Task {
            try? await repository.resetSettings()
        }
    }
}

// Helper function for synchronous bridge during migration
private func runAsyncAndBlock<T>(_ operation: @Sendable @escaping () async throws -> T) throws -> T? {
    let semaphore = DispatchSemaphore(value: 0)
    var result: T?
    var thrownError: Error?
    
    Task {
        do {
            result = try await operation()
        } catch {
            thrownError = error
        }
        semaphore.signal()
    }
    
    semaphore.wait()
    
    if let error = thrownError {
        throw error
    }
    return result
}
