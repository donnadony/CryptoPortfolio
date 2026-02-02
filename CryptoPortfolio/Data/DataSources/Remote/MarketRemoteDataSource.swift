//
//  MarketRemoteDataSource.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Protocol

protocol MarketRemoteDataSourceProtocol: Sendable {
    func fetchMarketData(limit: Int) async throws -> [CryptoMarketDTO]
    func searchCrypto(query: String) async throws -> [CryptoSearchResultDTO]
    func fetchCryptoDetail(id: String) async throws -> CryptoMarketDTO
}

// MARK: - Implementation

final class MarketRemoteDataSource: MarketRemoteDataSourceProtocol, @unchecked Sendable {
    
    private let apiService: APIServiceProtocol
    private let rateLimiter: RateLimiter
    
    init(apiService: APIServiceProtocol, rateLimiter: RateLimiter) {
        self.apiService = apiService
        self.rateLimiter = rateLimiter
    }
    
    func fetchMarketData(limit: Int) async throws -> [CryptoMarketDTO] {
        // Apply rate limiting
        await rateLimiter.waitIfNeeded()
        
        let queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: String(limit)),
            URLQueryItem(name: "sparkline", value: "false"),
            URLQueryItem(name: "locale", value: "en")
        ]
        
        print("🟡 [MarketRemoteDataSource] Requesting /coins/markets with limit: \(limit)")
        
        let cryptos: [CryptoMarketDTO] = try await apiService.request(
            endpoint: "/coins/markets",
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        print("🟢 [MarketRemoteDataSource] Fetched \(cryptos.count) cryptos")
        return cryptos
    }
    
    func searchCrypto(query: String) async throws -> [CryptoSearchResultDTO] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }
        
        // Apply rate limiting
        await rateLimiter.waitIfNeeded()
        
        let queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        
        print("🟡 [MarketRemoteDataSource] Requesting /search with query: '\(query)'")
        
        let response: SearchResponseDTO = try await apiService.request(
            endpoint: "/search",
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        print("🟢 [MarketRemoteDataSource] Search returned \(response.coins.count) coins")
        return response.coins
    }
    
    func fetchCryptoDetail(id: String) async throws -> CryptoMarketDTO {
        let queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "market_data", value: "true")
        ]
        
        let crypto: CryptoMarketDTO = try await apiService.request(
            endpoint: "/coins/\(id.lowercased())",
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        return crypto
    }
}
