//
//  MarketServiceProtocol.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import Foundation

protocol MarketServiceProtocol: Sendable {
    /// Fetch top cryptocurrencies by market cap
    /// - Parameter limit: Number of cryptocurrencies to fetch (default: 50)
    /// - Returns: Array of CryptoMarket objects
    func fetchMarketData(limit: Int) async throws -> [CryptoMarket]
    
    /// Search for a cryptocurrency by symbol or name
    /// - Parameter query: Search term (symbol or name)
    /// - Returns: Array of CryptoSearchResult objects
    func searchCrypto(query: String) async throws -> [CryptoSearchResult]
    
    /// Fetch detailed market data for a specific cryptocurrency
    /// - Parameter id: CoinGecko cryptocurrency ID
    /// - Returns: Detailed CryptoMarket data
    func fetchCryptoDetail(id: String) async throws -> CryptoMarket
}
