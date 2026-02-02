//
//  Route.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

/// Navigation routes for the app's main navigation stack
enum Route: Hashable, Equatable {
    
    // MARK: - Portfolio Routes
    
    case portfolio
    case assetDetail(Asset)
    case addAsset
    
    // MARK: - Market Routes
    
    case market
    
    // MARK: - Analytics Routes
    
    case analytics
    case analyticsExport
    
    // MARK: - Settings Routes
    
    case settings
}
