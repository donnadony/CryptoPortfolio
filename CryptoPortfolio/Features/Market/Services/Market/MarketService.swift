//
//  MarketService.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import Foundation

class MarketService: MarketServiceProtocol {
    // MARK: - Properties
    
    private let apiService: APIServiceProtocol
    
    // MARK: - Initialization
    
    nonisolated init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }
    
    // MARK: - MarketServiceProtocol
    
    func fetchMarketData(limit: Int = 50) async throws -> [CryptoMarket] {
        let queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: String(limit)),
            URLQueryItem(name: "sparkline", value: "false"),
            URLQueryItem(name: "locale", value: "en")
        ]
        
        let cryptos: [CryptoMarket] = try await apiService.request(
            endpoint: "/coins/markets",
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        return cryptos
    }
    
    func searchCrypto(query: String) async throws -> [CryptoSearchResult] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }
        
        let queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        
        let response: SearchResponse = try await apiService.request(
            endpoint: "/search",
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
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
