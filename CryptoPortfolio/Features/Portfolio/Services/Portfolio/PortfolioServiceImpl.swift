//
//  PortfolioServiceImpl.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

/// Service implementation that uses Repository pattern
final class PortfolioServiceImpl: PortfolioServiceProtocol, @unchecked Sendable {
    
    private let repository: PortfolioRepository
    
    init(repository: PortfolioRepository) {
        self.repository = repository
    }
    
    func fetchAssets() async throws -> [Asset] {
        try await repository.fetchAssets()
    }
    
    func addAsset(_ asset: Asset) async throws {
        try await repository.addAsset(asset)
    }
    
    func deleteAsset(id: String) async throws {
        try await repository.deleteAsset(id: id)
    }
    
    func updateAsset(_ asset: Asset) async throws {
        try await repository.updateAsset(asset)
    }
    
    func fetchPrice(symbol: String) async throws -> Double {
        try await repository.fetchPrice(symbol: symbol)
    }
    
    func fetchMarketData(symbol: String) async throws -> MarketDataResponse {
        try await repository.fetchMarketData(symbol: symbol)
    }
    
    func fetchPriceHistory(
        symbol: String,
        days: Int
    ) async throws -> [(timestamp: Date, price: Double)] {
        let history = try await repository.fetchPriceHistory(symbol: symbol, days: days)
        return history.map { ($0.timestamp, $0.price) }
    }
    
    func calculatePortfolioTotal() async throws -> PortfolioAssetsSummary {
        let assets = try await repository.fetchAssets()
        
        guard !assets.isEmpty else {
            return PortfolioAssetsSummary(
                assets: [],
                totalValue: 0,
                totalInvested: 0,
                gainLoss: 0,
                gainLossPercentage: 0
            )
        }
        
        var updatedAssets: [Asset] = []
        
        for asset in assets {
            do {
                let price = try await repository.fetchPrice(symbol: asset.symbol)
                let newAsset = Asset(
                    id: asset.id,
                    symbol: asset.symbol,
                    name: asset.name,
                    amount: asset.amount,
                    currentPrice: price
                )
                updatedAssets.append(newAsset)
                try? await repository.updateAsset(newAsset)
            } catch {
                updatedAssets.append(asset)
            }
        }
        
        let totalValue = updatedAssets.reduce(0) { $0 + $1.totalValue }
        let totalInvested = updatedAssets.reduce(0) { $0 + ($1.amount * $1.currentPrice) }
        let gainLoss = totalValue - totalInvested
        let gainLossPercentage = totalInvested > 0 ? (gainLoss / totalInvested) * 100 : 0
        
        return PortfolioAssetsSummary(
            assets: updatedAssets,
            totalValue: totalValue,
            totalInvested: totalInvested,
            gainLoss: gainLoss,
            gainLossPercentage: gainLossPercentage
        )
    }
}
