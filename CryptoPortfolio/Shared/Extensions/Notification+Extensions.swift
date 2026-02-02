//
//  Notification+Extensions.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Portfolio Notifications

extension Notification.Name {
    /// Posted when portfolio data changes (asset added, updated, or deleted)
    static let portfolioDidChange = Notification.Name("com.cryptoportfolio.portfolioDidChange")
    
    /// Posted when a new asset is added to the portfolio
    static let assetDidAdd = Notification.Name("com.cryptoportfolio.assetDidAdd")
    
    /// Posted when an asset is deleted from the portfolio
    static let assetDidDelete = Notification.Name("com.cryptoportfolio.assetDidDelete")
    
    /// Posted when an asset is updated
    static let assetDidUpdate = Notification.Name("com.cryptoportfolio.assetDidUpdate")
    
    /// Posted when market data is refreshed
    static let marketDataDidRefresh = Notification.Name("com.cryptoportfolio.marketDataDidRefresh")
    
    /// Posted when app theme changes
    static let themeDidChange = Notification.Name("com.cryptoportfolio.themeDidChange")
}

// MARK: - Notification Posting Helper

extension NotificationCenter {
    /// Post portfolio change notification on main thread
    @MainActor
    static func postPortfolioChange(userInfo: [String: Any]? = nil) {
        NotificationCenter.default.post(
            name: .portfolioDidChange,
            object: nil,
            userInfo: userInfo
        )
    }
}
