//
//  AssetDTO.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Asset DTOs

/// API Response model for asset data from CoinGecko
struct AssetPriceResponseDTO: Codable {
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

/// Simple price response from /simple/price endpoint
/// Format: { "bitcoin": { "usd": 45000.00 } }
typealias SimplePriceResponseDTO = [String: [String: Double]]

/// DTO for asset stored locally
struct AssetStorageDTO: Codable {
    let id: String
    let symbol: String
    let name: String
    let amount: Double
    let currentPrice: Double
    let savedAt: Date
    
    init(from asset: Asset) {
        self.id = asset.id
        self.symbol = asset.symbol
        self.name = asset.name
        self.amount = asset.amount
        self.currentPrice = asset.currentPrice
        self.savedAt = Date()
    }
    
    func toDomain() -> Asset {
        Asset(
            id: id,
            symbol: symbol,
            name: name,
            amount: amount,
            currentPrice: currentPrice
        )
    }
}

// MARK: - Market Data DTOs

/// API Response model for market data
struct MarketDataResponseDTO: Codable {
    let id: String
    let symbol: String
    let name: String
    let currentPrice: Double?
    let marketCap: Double?
    let marketCapRank: Int?
    let priceChangePercentage24h: Double?
    let image: String?
    
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

/// Price history response DTO
struct PriceHistoryResponseDTO: Codable {
    let prices: [[Double]]
    let marketCaps: [[Double]]?
    let volumes: [[Double]]?
    
    enum CodingKeys: String, CodingKey {
        case prices
        case marketCaps = "market_caps"
        case volumes
    }
    
    func toDomain() -> [(timestamp: Date, price: Double)] {
        prices.map { priceData in
            let timestamp = Date(timeIntervalSince1970: priceData[0] / 1000)
            let price = priceData[1]
            return (timestamp, price)
        }
    }
}

// MARK: - Search DTOs

/// Search result DTO from /search endpoint
struct CryptoSearchResultDTO: Codable {
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

/// Search response wrapper
struct SearchResponseDTO: Codable {
    let coins: [CryptoSearchResultDTO]
}

// MARK: - Crypto Market DTO

/// DTO for cryptocurrency market data from API
struct CryptoMarketDTO: Codable {
    let id: String
    let symbol: String
    let name: String
    let currentPrice: Double
    let marketCap: Double?
    let marketCapRank: Int?
    let priceChangePercentage24h: Double?
    let image: String?
    
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
