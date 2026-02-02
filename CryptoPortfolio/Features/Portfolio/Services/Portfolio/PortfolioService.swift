//
//  PortfolioService.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

/// Legacy PortfolioService - use PortfolioServiceImpl through DI Container instead
final class PortfolioService: PortfolioServiceProtocol, @unchecked Sendable {
    // MARK: - Properties
    
    private let apiService: APIServiceProtocol
    private let localStorage: LocalStorageProtocol
    
    private let portfolioKey = "crypto_portfolio_assets"
    
    // MARK: - Symbol to ID Mapping
    
    private let idMapping: [String: String] = [
        "btc": "bitcoin",
        "eth": "ethereum",
        "xrp": "ripple",
        "sol": "solana",
        "ada": "cardano",
        "dot": "polkadot",
        "doge": "dogecoin",
        "bnb": "binancecoin",
        "usdt": "tether",
        "usdc": "usd-coin"
    ]
    
    // MARK: - Initialization
    
    init(
        apiService: APIServiceProtocol,
        localStorage: LocalStorageProtocol
    ) {
        self.apiService = apiService
        self.localStorage = localStorage
    }
    
    // MARK: - PortfolioServiceProtocol Implementation
    
    func fetchAssets() async throws -> [Asset] {
        // Try to load from local storage first
        if let assets = try? await localStorage.fetch(forKey: portfolioKey, as: [Asset].self) {
            return assets
        }
        return []
    }
    
    func addAsset(_ asset: Asset) async throws {
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
    
    func updateAsset(_ asset: Asset) async throws {
        var assets = try await fetchAssets()
        
        if let index = assets.firstIndex(where: { $0.id == asset.id }) {
            assets[index] = asset
            try await localStorage.save(assets, forKey: portfolioKey)
        } else {
            throw NetworkError.notFound
        }
    }
    
    func fetchPrice(symbol: String) async throws -> Double {
        let query = idMapping[symbol.lowercased()] ?? symbol.lowercased()
        let endpoint = "/simple/price"
        
        let queryItems = [
            URLQueryItem(name: "ids", value: query),
            URLQueryItem(name: "vs_currencies", value: "usd")
        ]
        
        print("🟡 [PortfolioService] Fetching price for '\(symbol)' -> '\(query)'")
        
        let response: [String: [String: Double]] = try await apiService.request(
            endpoint: endpoint,
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        print("🟢 [PortfolioService] Price response keys: \(response.keys)")
        
        if let priceData = response[query],
           let price = priceData["usd"] {
            print("🟢 [PortfolioService] Found price for '\(query)': $\(price)")
            return price
        }
        
        // Try to find price with any key (fallback)
        if let firstKey = response.keys.first,
           let priceData = response[firstKey],
           let price = priceData["usd"] {
            print("🟡 [PortfolioService] Found price with fallback key '\(firstKey)': $\(price)")
            return price
        }
        
        print("🔴 [PortfolioService] Price not found for '\(query)'. Available keys: \(response.keys)")
        throw NetworkError.notFound
    }
    
    func fetchMarketData(symbol: String) async throws -> MarketDataResponse {
        let query = symbol.lowercased()
        let endpoint = "/coins/markets"
        
        let queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "ids", value: query),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: "1"),
            URLQueryItem(name: "sparkline", value: "false")
        ]
        
        let response: [MarketDataResponseDTO] = try await apiService.request(
            endpoint: endpoint,
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        guard let marketData = response.first else {
            throw NetworkError.notFound
        }
        
        return MarketDataMapper.map(dto: marketData)
    }
    
    func fetchPriceHistory(
        symbol: String,
        days: Int
    ) async throws -> [(timestamp: Date, price: Double)] {
        let query = symbol.lowercased()
        let endpoint = "/coins/\(query)/market_chart"
        
        let queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "days", value: String(days)),
            URLQueryItem(name: "interval", value: "daily")
        ]
        
        let response: PriceHistoryResponseDTO = try await apiService.request(
            endpoint: endpoint,
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        return response.toDomain()
    }
    
    func calculatePortfolioTotal() async throws -> PortfolioAssetsSummary {
        let assets = try await fetchAssets()
        
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
                let price = try await fetchPrice(symbol: asset.symbol)
                let newAsset = Asset(
                    id: asset.id,
                    symbol: asset.symbol,
                    name: asset.name,
                    amount: asset.amount,
                    currentPrice: price
                )
                updatedAssets.append(newAsset)
                try await updateAsset(newAsset)
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
