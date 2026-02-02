//
//  PortfolioLocalDataSource.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Local Data Source Protocol

protocol PortfolioLocalDataSourceProtocol: Sendable {
    /// Fetch all assets from local storage
    func fetchAssets() async throws -> [AssetStorageDTO]
    
    /// Save assets to local storage
    func saveAssets(_ assets: [AssetStorageDTO]) async throws
    
    /// Add a single asset
    func addAsset(_ asset: AssetStorageDTO) async throws
    
    /// Delete an asset by ID
    func deleteAsset(id: String) async throws
    
    /// Update an asset
    func updateAsset(_ asset: AssetStorageDTO) async throws
}

// MARK: - Implementation

/// Local data source for Portfolio-related storage operations
final class PortfolioLocalDataSource: PortfolioLocalDataSourceProtocol, @unchecked Sendable {
    
    private let localStorage: LocalStorageProtocol
    private let portfolioKey = "crypto_portfolio_assets"
    
    init(localStorage: LocalStorageProtocol) {
        self.localStorage = localStorage
    }
    
    func fetchAssets() async throws -> [AssetStorageDTO] {
        let assets = try await localStorage.fetch(forKey: portfolioKey, as: [AssetStorageDTO].self)
        return assets ?? []
    }
    
    func saveAssets(_ assets: [AssetStorageDTO]) async throws {
        try await localStorage.save(assets, forKey: portfolioKey)
    }
    
    func addAsset(_ asset: AssetStorageDTO) async throws {
        var assets = try await fetchAssets()
        
        // Remove if asset with same symbol already exists
        assets.removeAll { $0.symbol.lowercased() == asset.symbol.lowercased() }
        
        // Add new asset
        assets.append(asset)
        
        // Save to local storage
        try await localStorage.save(assets, forKey: portfolioKey)
    }
    
    func deleteAsset(id: String) async throws {
        var assets = try await fetchAssets()
        assets.removeAll { $0.id == id }
        try await localStorage.save(assets, forKey: portfolioKey)
    }
    
    func updateAsset(_ asset: AssetStorageDTO) async throws {
        var assets = try await fetchAssets()
        
        guard let index = assets.firstIndex(where: { $0.id == asset.id }) else {
            throw DomainError.assetNotFound
        }
        
        assets[index] = asset
        try await localStorage.save(assets, forKey: portfolioKey)
    }
}
