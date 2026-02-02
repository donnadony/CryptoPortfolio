//
//  SettingsService.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation

/// Implementation of SettingsServiceProtocol
/// Uses UserDefaults to persist application settings
final class SettingsService: SettingsServiceProtocol, @unchecked Sendable {
    // MARK: - Constants
    
    private enum UserDefaultsKeys {
        static let settings = "app_settings"
    }
    
    // MARK: - Properties
    
    private let userDefaults: UserDefaults
    private var cachedSettings: AppSettings?
    
    // MARK: - Initialization
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - SettingsServiceProtocol
    
    func loadSettings() -> AppSettings {
        // Return cached settings if available
        if let cached = cachedSettings {
            return cached
        }
        
        // Try to load from UserDefaults
        if let data = userDefaults.data(forKey: UserDefaultsKeys.settings) {
            do {
                let settings = try JSONDecoder().decode(AppSettings.self, from: data)
                cachedSettings = settings
                return settings
            } catch {
                // Fallback to default if decoding fails
                print("Failed to decode settings: \(error)")
                return AppSettings.default
            }
        }
        
        // Return default settings if nothing stored
        return AppSettings.default
    }
    
    func saveSettings(_ settings: AppSettings) {
        cachedSettings = settings
        
        do {
            let data = try JSONEncoder().encode(settings)
            userDefaults.set(data, forKey: UserDefaultsKeys.settings)
            userDefaults.synchronize()
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
    
    func resetSettings() {
        cachedSettings = AppSettings.default
        userDefaults.removeObject(forKey: UserDefaultsKeys.settings)
        userDefaults.synchronize()
    }
    
    func getCurrentSettings() -> AppSettings {
        return loadSettings()
    }
}
