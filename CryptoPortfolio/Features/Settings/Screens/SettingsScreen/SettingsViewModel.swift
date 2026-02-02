//
//  SettingsViewModel.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var settings: AppSettings = .default
    
    /// Unified view state
    @Published var state: ViewState<AppSettings> = .idle
    
    /// Typed error
    @Published var error: DomainError?
    
    let availableCurrencies = AppSettings.availableCurrencies
    let availableThemes = AppSettings.availableThemes
    let themeNames = AppSettings.themeNames
    
    /// Loading state
    var isLoading: Bool { state.isLoading }
    
    // MARK: - Dependencies (UseCases)
    
    private let loadSettingsUseCase: any LoadSettingsUseCaseProtocol
    private let saveSettingsUseCase: any SaveSettingsUseCaseProtocol
    
    // MARK: - Task Management
    
    private var loadTask: Task<Void, Never>?
    private var saveTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(
        loadSettingsUseCase: any LoadSettingsUseCaseProtocol,
        saveSettingsUseCase: any SaveSettingsUseCaseProtocol
    ) {
        self.loadSettingsUseCase = loadSettingsUseCase
        self.saveSettingsUseCase = saveSettingsUseCase
    }
    
    // MARK: - Public Methods
    
    /// Load settings with cancellation support
    func loadSettings() async {
        loadTask?.cancel()
        
        loadTask = Task { @MainActor in
            state = .loading
            error = nil
            
            do {
                let loadedSettings = try await loadSettingsUseCase.execute()
                
                guard !Task.isCancelled else { return }
                
                self.settings = loadedSettings
                self.state = .loaded(loadedSettings)
                self.error = nil
            } catch let domainError as DomainError {
                guard !Task.isCancelled else { return }
                self.state = .error(domainError)
                self.error = domainError
            } catch {
                guard !Task.isCancelled else { return }
                let wrappedError = DomainError.unknown(error.localizedDescription)
                self.state = .error(wrappedError)
                self.error = wrappedError
            }
        }
        
        await loadTask?.value
    }
    
    /// Update currency preference
    func updateCurrency(_ currency: String) async {
        settings.currency = currency
        await saveSettings()
    }
    
    /// Update theme preference
    func updateTheme(_ theme: String) async {
        settings.theme = theme
        await saveSettings()
        
        // Apply theme globally
        if let themeEnum = ThemeManager.Theme(rawValue: theme) {
            ThemeManager.shared.setTheme(themeEnum)
        }
    }
    
    /// Toggle notifications setting
    func toggleNotifications() async {
        settings.notificationsEnabled.toggle()
        await saveSettings()
    }
    
    /// Reset all settings to defaults
    func resetToDefaults() async {
        settings = AppSettings.default
        await saveSettings()
        ThemeManager.shared.setTheme(.system)
    }
    
    /// Get current settings
    func getCurrentSettings() -> AppSettings {
        settings
    }
    
    /// Clear error state
    func clearError() {
        error = nil
        if case .error = state {
            state = .loaded(settings)
        }
    }
    
    // MARK: - Private Methods
    
    private func saveSettings() async {
        do {
            try await saveSettingsUseCase.execute(settings)
            state = .loaded(settings)
            error = nil
        } catch let domainError as DomainError {
            self.error = domainError
        } catch {
            self.error = DomainError.unknown(error.localizedDescription)
        }
    }
}
