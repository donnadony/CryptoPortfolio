//
//  SettingsUseCases.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - LoadSettingsUseCase

protocol LoadSettingsUseCaseProtocol: Sendable {
    func execute() async throws -> AppSettings
}

final class LoadSettingsUseCase: LoadSettingsUseCaseProtocol {
    
    private let repository: SettingsRepository
    
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> AppSettings {
        try await repository.loadSettings()
    }
}

// MARK: - SaveSettingsUseCase

protocol SaveSettingsUseCaseProtocol: Sendable {
    func execute(_ settings: AppSettings) async throws
}

final class SaveSettingsUseCase: SaveSettingsUseCaseProtocol {
    
    private let repository: SettingsRepository
    
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func execute(_ settings: AppSettings) async throws {
        try await repository.saveSettings(settings)
    }
}

// MARK: - ResetSettingsUseCase

protocol ResetSettingsUseCaseProtocol: Sendable {
    func execute() async throws
}

final class ResetSettingsUseCase: ResetSettingsUseCaseProtocol {
    
    private let repository: SettingsRepository
    
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func execute() async throws {
        try await repository.resetSettings()
    }
}
