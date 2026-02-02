//
//  AppSettings.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation

/// Application settings model
/// Stores user preferences for currency, theme, and notifications
struct AppSettings: Codable, Equatable {
    // MARK: - Properties
    
    /// Selected currency for displaying prices (USD, EUR, GBP, JPY, BTC)
    var currency: String = "USD"
    
    /// Selected theme (light, dark, system)
    var theme: String = "system"
    
    /// Whether push notifications are enabled
    var notificationsEnabled: Bool = true
    
    // MARK: - Initialization
    
    init(
        currency: String = "USD",
        theme: String = "system",
        notificationsEnabled: Bool = true
    ) {
        self.currency = currency
        self.theme = theme
        self.notificationsEnabled = notificationsEnabled
    }
    
    // MARK: - Defaults
    
    /// Default settings
    static let `default` = AppSettings(
        currency: "USD",
        theme: "system",
        notificationsEnabled: true
    )
}

// MARK: - Currency Extension

extension AppSettings {
    /// Available currencies
    static let availableCurrencies = ["USD", "EUR", "GBP", "JPY", "BTC"]
    
    /// Currency symbols
    static let currencySymbols: [String: String] = [
        "USD": "$",
        "EUR": "€",
        "GBP": "£",
        "JPY": "¥",
        "BTC": "₿"
    ]
    
    /// Get symbol for current currency
    var currencySymbol: String {
        Self.currencySymbols[currency] ?? "$"
    }
}

// MARK: - Theme Extension

extension AppSettings {
    /// Available themes
    static let availableThemes = ["light", "dark", "system"]
    
    /// Theme display names
    static let themeNames: [String: String] = [
        "light": "Light",
        "dark": "Dark",
        "system": "System"
    ]
    
    /// Get display name for current theme
    var themeName: String {
        Self.themeNames[theme] ?? "System"
    }
}
