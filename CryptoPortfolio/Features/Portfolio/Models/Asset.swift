//
//  Asset.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

/// Domain entity representing a cryptocurrency asset in the portfolio
struct Asset: Codable, Identifiable, Equatable, Hashable, Sendable {
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

// MARK: - Portfolio Summary

/// Summary of portfolio assets with calculated totals
struct PortfolioAssetsSummary: Equatable, Sendable {
    let assets: [Asset]
    let totalValue: Double
    let totalInvested: Double
    let gainLoss: Double
    let gainLossPercentage: Double
}

// MARK: - Market Data Response (Domain Model)

/// Domain model for market data response
struct MarketDataResponse: Equatable, Sendable {
    let id: String
    let symbol: String
    let name: String
    let currentPrice: Double?
    let marketCap: Double?
    let marketCapRank: Int?
    let priceChangePercentage24h: Double?
}
