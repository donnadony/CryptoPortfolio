//
//  Constants.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
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
        static let portfolio = "portfolioAssets"
    }
    
    // MARK: - Default Values
    struct Defaults {
        static let currency = "usd"
        static let refreshInterval: TimeInterval = 60 // 60 seconds
    }
}
