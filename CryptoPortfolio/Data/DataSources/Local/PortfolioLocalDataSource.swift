//
//  PortfolioLocalDataSource.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation
import os.log

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
    
    /// Clear all stored assets (for migration/reset)
    func clearAssets() async
}

// MARK: - Implementation

/// Local data source for Portfolio-related storage operations
/// Includes migration support for legacy data formats
final class PortfolioLocalDataSource: PortfolioLocalDataSourceProtocol, @unchecked Sendable {
    
    private let localStorage: LocalStorageProtocol
    private let portfolioKey = "crypto_portfolio_assets"
    private let migrationKey = "crypto_portfolio_migrated_v2"
    
    private let logger = Logger(subsystem: "CryptoPortfolio", category: "PortfolioLocalDataSource")
    
    init(localStorage: LocalStorageProtocol) {
        self.localStorage = localStorage
    }
    
    // MARK: - Fetch with Migration Support
    
    func fetchAssets() async throws -> [AssetStorageDTO] {
        // Strategy 1: Try to decode with current format
        do {
            if let assets = try await localStorage.fetch(forKey: portfolioKey, as: [AssetStorageDTO].self) {
                return assets
            }
            return []
        } catch {
            logger.warning("Failed to decode assets with current format: \(error.localizedDescription)")
        }
        
        // Strategy 2: Try legacy format migration
        do {
            let migratedAssets = try await migrateFromLegacyFormat()
            if !migratedAssets.isEmpty {
                logger.info("Successfully migrated \(migratedAssets.count) assets from legacy format")
                return migratedAssets
            }
        } catch {
            logger.warning("Legacy migration failed: \(error.localizedDescription)")
        }
        
        // Strategy 3: Try raw JSON parsing as last resort
        do {
            let rescuedAssets = try await rescueFromRawJSON()
            if !rescuedAssets.isEmpty {
                logger.info("Rescued \(rescuedAssets.count) assets from raw JSON")
                return rescuedAssets
            }
        } catch {
            logger.warning("Raw JSON rescue failed: \(error.localizedDescription)")
        }
        
        // Strategy 4: Clear corrupted data and start fresh
        logger.error("All decode strategies failed. Clearing corrupted portfolio data.")
        await clearAssets()
        
        return []
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
    
    func clearAssets() async {
        await localStorage.delete(forKey: portfolioKey)
    }
    
    // MARK: - Migration Helpers
    
    /// Attempt to migrate from legacy format
    private func migrateFromLegacyFormat() async throws -> [AssetStorageDTO] {
        guard let legacyAssets = try await localStorage.fetch(
            forKey: portfolioKey,
            as: [LegacyAssetStorageDTO].self
        ) else {
            return []
        }
        
        let migratedAssets = legacyAssets.map { $0.toCurrentDTO() }
        
        // Save in new format
        if !migratedAssets.isEmpty {
            try await localStorage.save(migratedAssets, forKey: portfolioKey)
        }
        
        return migratedAssets
    }
    
    /// Last resort: try to parse raw JSON and extract what we can
    private func rescueFromRawJSON() async throws -> [AssetStorageDTO] {
        // Get raw data from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: portfolioKey) else {
            return []
        }
        
        // Try to parse as generic JSON
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        
        var rescuedAssets: [AssetStorageDTO] = []
        
        for jsonDict in jsonArray {
            // Extract whatever fields we can find
            let id = (jsonDict["id"] as? String) ?? UUID().uuidString
            let symbol = (jsonDict["symbol"] as? String) ?? ""
            let name = (jsonDict["name"] as? String) ?? ""
            let amount = (jsonDict["amount"] as? Double) ?? 0.0
            
            // Try multiple keys for price
            let currentPrice = (jsonDict["current_price"] as? Double)
                ?? (jsonDict["currentPrice"] as? Double)
                ?? 0.0
            
            // Skip if we don't have essential data
            guard !symbol.isEmpty else { continue }
            
            let asset = AssetStorageDTO(
                id: id,
                symbol: symbol,
                name: name.isEmpty ? symbol.uppercased() : name,
                amount: amount,
                currentPrice: currentPrice
            )
            rescuedAssets.append(asset)
        }
        
        // Save rescued assets in new format
        if !rescuedAssets.isEmpty {
            try await localStorage.save(rescuedAssets, forKey: portfolioKey)
        }
        
        return rescuedAssets
    }
}
