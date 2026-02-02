//
//  MarketRepository.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Repository Protocol

protocol MarketRepository: Sendable {
    func fetchMarketData(limit: Int) async throws -> [CryptoMarket]
    func searchCrypto(query: String) async throws -> [CryptoSearchResult]
    func fetchCryptoDetail(id: String) async throws -> CryptoMarket
}

// MARK: - Implementation

final class MarketRepositoryImpl: MarketRepository, @unchecked Sendable {
    
    private let remoteDataSource: MarketRemoteDataSourceProtocol
    
    init(remoteDataSource: MarketRemoteDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchMarketData(limit: Int) async throws -> [CryptoMarket] {
        do {
            let dtos = try await remoteDataSource.fetchMarketData(limit: limit)
            return CryptoMarketMapper.map(dtos: dtos)
        } catch let error as NetworkError {
            throw DomainError.from(networkError: error)
        }
    }
    
    func searchCrypto(query: String) async throws -> [CryptoSearchResult] {
        do {
            let dtos = try await remoteDataSource.searchCrypto(query: query)
            return CryptoMarketMapper.map(dtos: dtos)
        } catch let error as NetworkError {
            throw DomainError.from(networkError: error)
        }
    }
    
    func fetchCryptoDetail(id: String) async throws -> CryptoMarket {
        do {
            let dto = try await remoteDataSource.fetchCryptoDetail(id: id)
            return CryptoMarketMapper.map(dto: dto)
        } catch let error as NetworkError {
            throw DomainError.from(networkError: error)
        }
    }
}
