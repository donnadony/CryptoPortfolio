//
//  PortfolioRepository.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Repository Protocol

/// Repository protocol for Portfolio operations
protocol PortfolioRepository: Sendable {
    /// Fetch all assets
    func fetchAssets() async throws -> [Asset]
    
    /// Add a new asset
    func addAsset(_ asset: Asset) async throws
    
    /// Delete an asset
    func deleteAsset(id: String) async throws
    
    /// Update an asset
    func updateAsset(_ asset: Asset) async throws
    
    /// Fetch current price for a symbol
    func fetchPrice(symbol: String) async throws -> Double
    
    /// Fetch market data for a symbol
    func fetchMarketData(symbol: String) async throws -> MarketDataResponse
    
    /// Fetch price history
    func fetchPriceHistory(symbol: String, days: Int) async throws -> [PriceHistoryPoint]
}

// MARK: - Implementation

/// Implementation of PortfolioRepository
final class PortfolioRepositoryImpl: PortfolioRepository, @unchecked Sendable {
    
    private let remoteDataSource: PortfolioRemoteDataSourceProtocol
    private let localDataSource: PortfolioLocalDataSourceProtocol
    
    init(
        remoteDataSource: PortfolioRemoteDataSourceProtocol,
        localDataSource: PortfolioLocalDataSourceProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func fetchAssets() async throws -> [Asset] {
        let dtos = try await localDataSource.fetchAssets()
        return dtos.map { $0.toDomain() }
    }
    
    func addAsset(_ asset: Asset) async throws {
        let dto = AssetStorageDTO(from: asset)
        try await localDataSource.addAsset(dto)
    }
    
    func deleteAsset(id: String) async throws {
        try await localDataSource.deleteAsset(id: id)
    }
    
    func updateAsset(_ asset: Asset) async throws {
        let dto = AssetStorageDTO(from: asset)
        try await localDataSource.updateAsset(dto)
    }
    
    func fetchPrice(symbol: String) async throws -> Double {
        do {
            return try await remoteDataSource.fetchPrice(symbol: symbol)
        } catch let error as NetworkError {
            throw DomainError.from(networkError: error)
        }
    }
    
    func fetchMarketData(symbol: String) async throws -> MarketDataResponse {
        do {
            let dto = try await remoteDataSource.fetchMarketData(symbol: symbol)
            return MarketDataMapper.map(dto: dto)
        } catch let error as NetworkError {
            throw DomainError.from(networkError: error)
        }
    }
    
    func fetchPriceHistory(symbol: String, days: Int) async throws -> [PriceHistoryPoint] {
        do {
            let dto = try await remoteDataSource.fetchPriceHistory(symbol: symbol, days: days)
            return dto.prices.map { priceData in
                PriceHistoryPoint(
                    timestamp: Date(timeIntervalSince1970: priceData[0] / 1000),
                    price: priceData[1]
                )
            }
        } catch let error as NetworkError {
            throw DomainError.from(networkError: error)
        }
    }
}
