//
//  PortfolioServiceProtocol.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation

protocol PortfolioServiceProtocol: Sendable {
    /// Fetch all assets from local storage
    func fetchAssets() async throws -> [Asset]
    
    /// Add a new asset to the portfolio
    func addAsset(_ asset: Asset) async throws
    
    /// Delete an asset from the portfolio
    func deleteAsset(id: String) async throws
    
    /// Update an existing asset
    func updateAsset(_ asset: Asset) async throws
    
    /// Fetch current price for a cryptocurrency
    func fetchPrice(symbol: String) async throws -> Double
    
    /// Fetch market data for a cryptocurrency
    func fetchMarketData(symbol: String) async throws -> MarketDataResponse
    
    /// Fetch price history for a cryptocurrency
    func fetchPriceHistory(
        symbol: String,
        days: Int
    ) async throws -> [(timestamp: Date, price: Double)]
    
    /// Calculate total portfolio value
    func calculatePortfolioTotal() async throws -> PortfolioAssetsSummary
}
