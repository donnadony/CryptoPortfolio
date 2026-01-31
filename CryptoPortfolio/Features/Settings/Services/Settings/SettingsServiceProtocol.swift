//
//  SettingsServiceProtocol.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import Foundation

/// Protocol for managing application settings
/// Handles loading, saving, and resetting user preferences
protocol SettingsServiceProtocol: AnyObject {
    /// Load current settings from persistent storage
    /// - Returns: Loaded settings or default settings
    func loadSettings() -> AppSettings
    
    /// Save settings to persistent storage
    /// - Parameter settings: Settings to save
    func saveSettings(_ settings: AppSettings)
    
    /// Reset settings to default values
    func resetSettings()
    
    /// Get current settings (convenience method)
    func getCurrentSettings() -> AppSettings
}
