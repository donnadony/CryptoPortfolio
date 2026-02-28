//
//  Constants.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation

struct Constants {
    // MARK: - App Info
    static let appName = "CryptoPortfolio"
    static let bundleID = Bundle.main.bundleIdentifier ?? ""
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    // MARK: - User Defaults Keys
    struct UserDefaultsKeys {
        static let currency = "selectedCurrency"
        static let theme = "selectedTheme"
        // Must match the key used in PortfolioLocalDataSource
        static let portfolio = "crypto_portfolio_assets"
    }
    
    // MARK: - Default Values
    struct Defaults {
        static let currency = "usd"
        static let refreshInterval: TimeInterval = 60 // 60 seconds
    }
}
