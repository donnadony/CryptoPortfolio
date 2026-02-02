//
//  Asset.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation

struct Asset: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let symbol: String
    let name: String
    let amount: Double
    let currentPrice: Double
    let totalValue: Double
    
    init(
        id: String = UUID().uuidString,
        symbol: String,
        name: String,
        amount: Double,
        currentPrice: Double
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.amount = amount
        self.currentPrice = currentPrice
        self.totalValue = amount * currentPrice
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case amount
        case currentPrice = "current_price"
        case totalValue = "total_value"
    }
    
    // MARK: - Computed Properties
    
    var isPositive: Bool {
        totalValue >= 0
    }
    
    var formattedValue: String {
        String(format: "$%.2f", totalValue)
    }
    
    var formattedPrice: String {
        String(format: "$%.2f", currentPrice)
    }
    
    var formattedAmount: String {
        String(format: "%.8f", amount)
    }
}

// MARK: - API Response Models

struct AssetAPIResponse: Codable {
    let id: String
    let symbol: String
    let name: String
    let currentPrice: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case currentPrice = "current_price"
    }
}

struct MarketDataResponse: Codable {
    let id: String
    let symbol: String
    let name: String
    let currentPrice: Double?
    let marketCap: Double?
    let marketCapRank: Int?
    let priceChangePercentage24h: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case priceChangePercentage24h = "price_change_percentage_24h"
    }
}

struct PriceResponse: Codable {
    let prices: [[Double]]
    let marketCaps: [[Double]]?
    let volumes: [[Double]]?
    
    enum CodingKeys: String, CodingKey {
        case prices
        case marketCaps = "market_caps"
        case volumes
    }
}

struct PortfolioAssetsSummary: Codable {
    let assets: [Asset]
    let totalValue: Double
    let totalInvested: Double
    let gainLoss: Double
    let gainLossPercentage: Double
    
    enum CodingKeys: String, CodingKey {
        case assets
        case totalValue = "total_value"
        case totalInvested = "total_invested"
        case gainLoss = "gain_loss"
        case gainLossPercentage = "gain_loss_percentage"
    }
}
