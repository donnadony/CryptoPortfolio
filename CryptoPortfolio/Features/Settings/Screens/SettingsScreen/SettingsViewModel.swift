//
//  SettingsViewModel.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import Foundation
import Combine

/// ViewModel for the Settings screen
/// Manages user preferences and application settings
@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Current application settings
    @Published var settings: AppSettings = .default
    
    /// Available currencies for selection
    let availableCurrencies = AppSettings.availableCurrencies
    
    /// Available themes for selection
    let availableThemes = AppSettings.availableThemes
    
    /// Theme display names mapping
    let themeNames = AppSettings.themeNames
    
    // MARK: - Private Properties
    
    private let service: SettingsServiceProtocol
    
    // MARK: - Initialization
    
    init(service: SettingsServiceProtocol = SettingsService()) {
        self.service = service
        self.settings = service.loadSettings()
    }
    
    // MARK: - Public Methods
    
    /// Update currency preference
    /// - Parameter currency: Selected currency code (USD, EUR, GBP, JPY, BTC)
    func updateCurrency(_ currency: String) {
        settings.currency = currency
        service.saveSettings(settings)
    }
    
    /// Update theme preference
    /// - Parameter theme: Selected theme (light, dark, system)
    func updateTheme(_ theme: String) {
        settings.theme = theme
        service.saveSettings(settings)
    }
    
    /// Toggle notifications setting
    func toggleNotifications() {
        settings.notificationsEnabled.toggle()
        service.saveSettings(settings)
    }
    
    /// Reset all settings to defaults
    func resetToDefaults() {
        settings = AppSettings.default
        service.resetSettings()
    }
    
    /// Get current settings
    /// - Returns: Current AppSettings
    func getCurrentSettings() -> AppSettings {
        return service.getCurrentSettings()
    }
}
