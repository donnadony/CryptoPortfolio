//
//  PortfolioService.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import Foundation

class PortfolioService: PortfolioServiceProtocol {
    // MARK: - Properties
    
    private let apiService: APIServiceProtocol
    private let userDefaults: UserDefaults
    
    private let portfolioKey = "crypto_portfolio_assets"
    private let coingeckoBaseURL = "https://api.coingecko.com/api/v3"
    
    // MARK: - Initialization
    
    init(
        apiService: APIServiceProtocol = APIService.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.apiService = apiService
        self.userDefaults = userDefaults
    }
    
    // MARK: - PortfolioServiceProtocol Implementation
    
    func fetchAssets() async throws -> [Asset] {
        // Try to load from local storage first
        if let data = userDefaults.data(forKey: portfolioKey),
           let assets = try? JSONDecoder().decode([Asset].self, from: data) {
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
        let encoded = try JSONEncoder().encode(assets)
        userDefaults.set(encoded, forKey: portfolioKey)
    }
    
    func deleteAsset(id: String) async throws {
        var assets = try await fetchAssets()
        assets.removeAll { $0.id == id }
        
        let encoded = try JSONEncoder().encode(assets)
        userDefaults.set(encoded, forKey: portfolioKey)
    }
    
    func updateAsset(_ asset: Asset) async throws {
        var assets = try await fetchAssets()
        
        if let index = assets.firstIndex(where: { $0.id == asset.id }) {
            assets[index] = asset
            
            let encoded = try JSONEncoder().encode(assets)
            userDefaults.set(encoded, forKey: portfolioKey)
        } else {
            throw NetworkError.notFound
        }
    }
    
    func fetchPrice(symbol: String) async throws -> Double {
        let query = symbol.lowercased()
        let endpoint = "/simple/price"
        
        let queryItems = [
            URLQueryItem(name: "ids", value: query),
            URLQueryItem(name: "vs_currencies", value: "usd")
        ]
        
        // Create a custom response structure for this specific call
        struct PriceResponse: Codable {
            let btc: [String: Double]?
            let eth: [String: Double]?
            let xrp: [String: Double]?
            
            subscript(key: String) -> [String: Double]? {
                let mirror = Mirror(reflecting: self)
                for child in mirror.children {
                    if child.label == key.lowercased() {
                        return child.value as? [String: Double]
                    }
                }
                return nil
            }
        }
        
        let response: [String: [String: Double]] = try await apiService.request(
            endpoint: endpoint,
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        if let priceData = response[query.lowercased()],
           let price = priceData["usd"] {
            return price
        }
        
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
        
        let response: [MarketDataResponse] = try await apiService.request(
            endpoint: endpoint,
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        guard let marketData = response.first else {
            throw NetworkError.notFound
        }
        
        return marketData
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
        
        let response: PriceResponse = try await apiService.request(
            endpoint: endpoint,
            method: .get,
            body: nil,
            queryItems: queryItems
        )
        
        let priceHistory = response.prices.map { priceData -> (timestamp: Date, price: Double) in
            let timestamp = Date(timeIntervalSince1970: priceData[0] / 1000)
            let price = priceData[1]
            return (timestamp, price)
        }
        
        return priceHistory
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
        
        // Update asset prices with current market data
        var updatedAssets: [Asset] = []
        
        for asset in assets {
            do {
                let price = try await fetchPrice(symbol: asset.symbol)
                var updatedAsset = asset
                
                // We need to update the asset with new price
                // Since we can't directly modify totalValue, we create a new Asset
                let newAsset = Asset(
                    id: asset.id,
                    symbol: asset.symbol,
                    name: asset.name,
                    amount: asset.amount,
                    currentPrice: price
                )
                updatedAssets.append(newAsset)
                
                // Save updated asset
                try await updateAsset(newAsset)
            } catch {
                // If price fetch fails, keep the old asset
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
