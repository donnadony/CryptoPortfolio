//
//  PortfolioRemoteDataSource.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Remote Data Source Protocol

protocol PortfolioRemoteDataSourceProtocol: Sendable {
    /// Fetch current price for a cryptocurrency
    func fetchPrice(symbol: String) async throws -> Double
    
    /// Fetch market data for a cryptocurrency
    func fetchMarketData(symbol: String) async throws -> MarketDataResponseDTO
    
    /// Fetch price history for a cryptocurrency
    func fetchPriceHistory(symbol: String, days: Int) async throws -> PriceHistoryResponseDTO
}

// MARK: - Implementation

/// Remote data source for Portfolio-related API calls
final class PortfolioRemoteDataSource: PortfolioRemoteDataSourceProtocol, @unchecked Sendable {
    
    private let apiService: APIServiceProtocol
    
    // Symbol to CoinGecko ID mapping
    private let idMapping: [String: String] = [
        "btc": "bitcoin",
        "eth": "ethereum",
        "xrp": "ripple",
        "sol": "solana",
        "ada": "cardano",
        "dot": "polkadot",
        "doge": "dogecoin",
        "bnb": "binancecoin",
        "usdt": "tether",
        "usdc": "usd-coin"
    ]
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    func fetchPrice(symbol: String) async throws -> Double {
        let query = idMapping[symbol.lowercased()] ?? symbol.lowercased()
        let endpoint = "/simple/price"
        
        let queryItems = [
            URLQueryItem(name: "ids", value: query),
            URLQueryItem(name: "vs_currencies", value: "usd")
        ]
        
        print("🟡 [PortfolioRemoteDataSource] Fetching price for '\(symbol)' -> '\(query)'")
        
        let response: SimplePriceResponseDTO = try await apiService.request(
            endpoint: endpoint,
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        print("🟢 [PortfolioRemoteDataSource] Price response keys: \(response.keys)")
        
        // Try to get price with the mapped query key
        if let priceData = response[query],
           let price = priceData["usd"] {
            print("🟢 [PortfolioRemoteDataSource] Found price for '\(query)': $\(price)")
            return price
        }
        
        // Try to find price with any key (fallback)
        if let firstKey = response.keys.first,
           let priceData = response[firstKey],
           let price = priceData["usd"] {
            print("🟡 [PortfolioRemoteDataSource] Found price with fallback key '\(firstKey)': $\(price)")
            return price
        }
        
        print("🔴 [PortfolioRemoteDataSource] Price not found for '\(query)'. Available keys: \(response.keys)")
        throw DomainError.assetNotFound
    }
    
    func fetchMarketData(symbol: String) async throws -> MarketDataResponseDTO {
        let query = symbol.lowercased()
        let endpoint = "/coins/markets"
        
        let queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "ids", value: query),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: "1"),
            URLQueryItem(name: "sparkline", value: "false")
        ]
        
        let response: [MarketDataResponseDTO] = try await apiService.request(
            endpoint: endpoint,
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        guard let marketData = response.first else {
            throw DomainError.assetNotFound
        }
        
        return marketData
    }
    
    func fetchPriceHistory(symbol: String, days: Int) async throws -> PriceHistoryResponseDTO {
        let query = symbol.lowercased()
        let endpoint = "/coins/\(query)/market_chart"
        
        let queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "days", value: String(days)),
            URLQueryItem(name: "interval", value: "daily")
        ]
        
        let response: PriceHistoryResponseDTO = try await apiService.request(
            endpoint: endpoint,
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        return response
    }
}
