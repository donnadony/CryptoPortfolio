//
//  MarketUseCases.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - FetchMarketDataUseCase

protocol FetchMarketDataUseCaseProtocol: Sendable {
    func execute(limit: Int) async throws -> [CryptoMarket]
}

final class FetchMarketDataUseCase: FetchMarketDataUseCaseProtocol {
    
    private let repository: MarketRepository
    
    init(repository: MarketRepository) {
        self.repository = repository
    }
    
    func execute(limit: Int) async throws -> [CryptoMarket] {
        try await repository.fetchMarketData(limit: limit)
    }
}

// MARK: - SearchCryptoUseCase

protocol SearchCryptoUseCaseProtocol: Sendable {
    func execute(query: String) async throws -> [CryptoSearchResult]
}

final class SearchCryptoUseCase: SearchCryptoUseCaseProtocol {
    
    private let repository: MarketRepository
    
    init(repository: MarketRepository) {
        self.repository = repository
    }
    
    func execute(query: String) async throws -> [CryptoSearchResult] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }
        return try await repository.searchCrypto(query: query)
    }
}

// MARK: - FetchCryptoDetailUseCase

protocol FetchCryptoDetailUseCaseProtocol: Sendable {
    func execute(id: String) async throws -> CryptoMarket
}

final class FetchCryptoDetailUseCase: FetchCryptoDetailUseCaseProtocol {
    
    private let repository: MarketRepository
    
    init(repository: MarketRepository) {
        self.repository = repository
    }
    
    func execute(id: String) async throws -> CryptoMarket {
        try await repository.fetchCryptoDetail(id: id)
    }
}
