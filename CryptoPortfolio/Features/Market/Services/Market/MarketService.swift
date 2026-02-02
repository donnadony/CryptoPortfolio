//
//  MarketService.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

/// Legacy MarketService - use MarketServiceImpl through DI Container instead
final class MarketService: MarketServiceProtocol, @unchecked Sendable {
    // MARK: - Properties
    
    private let apiService: APIServiceProtocol
    
    // MARK: - Initialization
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    // MARK: - MarketServiceProtocol
    
    func fetchMarketData(limit: Int = 50) async throws -> [CryptoMarket] {
        // Apply rate limiting using shared RateLimiter
        // Note: In production, inject this dependency
        
        let queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: String(limit)),
            URLQueryItem(name: "sparkline", value: "false"),
            URLQueryItem(name: "locale", value: "en")
        ]
        
        print("🟡 [MarketService] Requesting /coins/markets with limit: \(limit)")
        
        let cryptos: [CryptoMarket] = try await apiService.request(
            endpoint: "/coins/markets",
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        print("🟢 [MarketService] Fetched \(cryptos.count) cryptos")
        return cryptos
    }
    
    func searchCrypto(query: String) async throws -> [CryptoSearchResult] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }
        
        let queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        
        print("🟡 [MarketService] Requesting /search with query: '\(query)'")
        
        let response: SearchResponse = try await apiService.request(
            endpoint: "/search",
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        print("🟢 [MarketService] Search returned \(response.coins.count) coins")
        return response.coins
    }
    
    func fetchCryptoDetail(id: String) async throws -> CryptoMarket {
        let queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "market_data", value: "true")
        ]
        
        let crypto: CryptoMarket = try await apiService.request(
            endpoint: "/coins/\(id.lowercased())",
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        return crypto
    }
}
