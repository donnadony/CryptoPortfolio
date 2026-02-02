//
//  MarketServiceImpl.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

/// Service implementation that uses Repository pattern
final class MarketServiceImpl: MarketServiceProtocol, @unchecked Sendable {
    
    private let repository: MarketRepository
    
    init(repository: MarketRepository) {
        self.repository = repository
    }
    
    func fetchMarketData(limit: Int) async throws -> [CryptoMarket] {
        try await repository.fetchMarketData(limit: limit)
    }
    
    func searchCrypto(query: String) async throws -> [CryptoSearchResult] {
        try await repository.searchCrypto(query: query)
    }
    
    func fetchCryptoDetail(id: String) async throws -> CryptoMarket {
        try await repository.fetchCryptoDetail(id: id)
    }
}
