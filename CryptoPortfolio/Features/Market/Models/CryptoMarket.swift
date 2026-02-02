//
//  CryptoMarket.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation

struct CryptoMarket: Codable, Identifiable, Hashable {
    // MARK: - Properties
    let id: String
    let symbol: String
    let name: String
    let currentPrice: Double
    let marketCap: Double?
    let marketCapRank: Int?
    let priceChangePercentage24h: Double?
    let image: String?
    
    // MARK: - Computed Properties
    
    var isPositiveChange: Bool {
        guard let change = priceChangePercentage24h else { return false }
        return change >= 0
    }
    
    var formattedPrice: String {
        String(format: "$%.2f", currentPrice)
    }
    
    var formattedMarketCap: String? {
        guard let marketCap = marketCap, marketCap > 0 else { return nil }
        return formatLargeNumber(marketCap)
    }
    
    var formattedPriceChange: String? {
        guard let change = priceChangePercentage24h else { return nil }
        let sign = change >= 0 ? "+" : ""
        return String(format: "%@%.2f%%", sign, change)
    }
    
    // MARK: - Private Methods
    
    private func formatLargeNumber(_ number: Double) -> String {
        let trillion = number / 1_000_000_000_000
        let billion = number / 1_000_000_000
        let million = number / 1_000_000
        
        if abs(trillion) >= 1 {
            return String(format: "$%.2fT", trillion)
        } else if abs(billion) >= 1 {
            return String(format: "$%.2fB", billion)
        } else if abs(million) >= 1 {
            return String(format: "$%.2fM", million)
        } else {
            return String(format: "$%.0f", number)
        }
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case image
    }
}

// MARK: - API Response Model

struct CryptoMarketResponse: Codable {
    let cryptocurrencies: [CryptoMarket]
    
    enum CodingKeys: String, CodingKey {
        case cryptocurrencies = "coins"
    }
}

// MARK: - Search Result Model

struct CryptoSearchResult: Codable, Identifiable {
    let id: String
    let name: String
    let symbol: String
    let marketCapRank: Int?
    let thumb: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case marketCapRank = "market_cap_rank"
        case thumb
    }
}

struct SearchResponse: Codable {
    let coins: [CryptoSearchResult]
}
