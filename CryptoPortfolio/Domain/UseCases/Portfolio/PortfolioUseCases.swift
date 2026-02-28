//
//  PortfolioUseCases.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - GetAssetsUseCase

protocol GetAssetsUseCaseProtocol: Sendable {
    func execute() async throws -> [Asset]
}

final class GetAssetsUseCase: GetAssetsUseCaseProtocol {
    
    private let repository: PortfolioRepository
    
    init(repository: PortfolioRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [Asset] {
        try await repository.fetchAssets()
    }
}

// MARK: - AddAssetUseCase

protocol AddAssetUseCaseProtocol: Sendable {
    func execute(_ asset: Asset) async throws
}

final class AddAssetUseCase: AddAssetUseCaseProtocol {
    
    private let repository: PortfolioRepository
    
    init(repository: PortfolioRepository) {
        self.repository = repository
    }
    
    func execute(_ asset: Asset) async throws {
        // Validation
        guard !asset.symbol.isEmpty else {
            throw DomainError.invalidSymbol
        }
        guard asset.amount > 0 else {
            throw DomainError.invalidAmount
        }
        guard asset.currentPrice > 0 else {
            throw DomainError.invalidAssetData
        }
        
        try await repository.addAsset(asset)
    }
}

// MARK: - UpdateAssetUseCase

protocol UpdateAssetUseCaseProtocol: Sendable {
    func execute(_ asset: Asset) async throws
}

final class UpdateAssetUseCase: UpdateAssetUseCaseProtocol {
    
    private let repository: PortfolioRepository
    
    init(repository: PortfolioRepository) {
        self.repository = repository
    }
    
    func execute(_ asset: Asset) async throws {
        // Validation
        guard asset.amount > 0 else {
            throw DomainError.invalidAmount
        }
        
        try await repository.updateAsset(asset)
    }
}

// MARK: - DeleteAssetUseCase

protocol DeleteAssetUseCaseProtocol: Sendable {
    func execute(id: String) async throws
}

final class DeleteAssetUseCase: DeleteAssetUseCaseProtocol {
    
    private let repository: PortfolioRepository
    
    init(repository: PortfolioRepository) {
        self.repository = repository
    }
    
    func execute(id: String) async throws {
        try await repository.deleteAsset(id: id)
    }
}

// MARK: - CalculatePortfolioTotalUseCase

protocol CalculatePortfolioTotalUseCaseProtocol: Sendable {
    func execute() async throws -> PortfolioData
}

final class CalculatePortfolioTotalUseCase: CalculatePortfolioTotalUseCaseProtocol {
    
    private let repository: PortfolioRepository
    
    init(repository: PortfolioRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> PortfolioData {
        let assets = try await repository.fetchAssets()
        
        guard !assets.isEmpty else {
            return PortfolioData(
                assets: [],
                totalValue: 0,
                gainLoss: 0,
                gainLossPercentage: 0
            )
        }
        
        // Update asset prices with current market data
        var updatedAssets: [Asset] = []
        
        for asset in assets {
            do {
                let price = try await repository.fetchPrice(symbol: asset.symbol)
                // Preserve the original purchasePrice — only update currentPrice
                let newAsset = Asset(
                    id: asset.id,
                    symbol: asset.symbol,
                    name: asset.name,
                    amount: asset.amount,
                    currentPrice: price,
                    purchasePrice: asset.purchasePrice,
                    iconURL: asset.iconURL
                )
                updatedAssets.append(newAsset)
                
                // Save updated asset
                try? await repository.updateAsset(newAsset)
            } catch {
                // If price fetch fails, keep the old asset
                updatedAssets.append(asset)
            }
        }
        
        // Calculate totals using purchasePrice for true gain/loss
        let totalValue = updatedAssets.reduce(0) { $0 + $1.totalValue }
        let totalInvested = updatedAssets.reduce(0) { $0 + ($1.purchasePrice * $1.amount) }
        let gainLoss = totalValue - totalInvested
        let gainLossPercentage = totalInvested > 0 ? (gainLoss / totalInvested) * 100 : 0
        
        return PortfolioData(
            assets: updatedAssets,
            totalValue: totalValue,
            gainLoss: gainLoss,
            gainLossPercentage: gainLossPercentage
        )
    }
}

// MARK: - FetchPriceUseCase

protocol FetchPriceUseCaseProtocol: Sendable {
    func execute(symbol: String) async throws -> Double
}

final class FetchPriceUseCase: FetchPriceUseCaseProtocol {
    
    private let repository: PortfolioRepository
    
    init(repository: PortfolioRepository) {
        self.repository = repository
    }
    
    func execute(symbol: String) async throws -> Double {
        guard !symbol.isEmpty else {
            throw DomainError.invalidSymbol
        }
        return try await repository.fetchPrice(symbol: symbol)
    }
}

// MARK: - PortfolioFetchMarketDataUseCase

protocol PortfolioFetchMarketDataUseCaseProtocol: Sendable {
    func execute(symbol: String) async throws -> MarketDataResponse
}

final class PortfolioFetchMarketDataUseCase: PortfolioFetchMarketDataUseCaseProtocol {
    
    private let repository: PortfolioRepository
    
    init(repository: PortfolioRepository) {
        self.repository = repository
    }
    
    func execute(symbol: String) async throws -> MarketDataResponse {
        try await repository.fetchMarketData(symbol: symbol)
    }
}

// MARK: - FetchPriceHistoryUseCase

protocol FetchPriceHistoryUseCaseProtocol: Sendable {
    func execute(symbol: String, days: Int) async throws -> [PriceHistoryPoint]
}

final class FetchPriceHistoryUseCase: FetchPriceHistoryUseCaseProtocol {
    
    private let repository: PortfolioRepository
    
    init(repository: PortfolioRepository) {
        self.repository = repository
    }
    
    func execute(symbol: String, days: Int) async throws -> [PriceHistoryPoint] {
        try await repository.fetchPriceHistory(symbol: symbol, days: days)
    }
}
