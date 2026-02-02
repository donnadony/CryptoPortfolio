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
    
    // MARK: - CodingKeys (support both snake_case and camelCase)
    
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case amount
        case currentPrice = "current_price"
        case currentPriceCamel = "currentPrice"
        case savedAt = "saved_at"
        case savedAtCamel = "savedAt"
        case totalValue = "total_value"  // Old format field (ignored but accepted)
    }
    
    // MARK: - Initialization
    
    init(id: String, symbol: String, name: String, amount: Double, currentPrice: Double, savedAt: Date = Date()) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.amount = amount
        self.currentPrice = currentPrice
        self.savedAt = savedAt
    }
    
    init(from asset: Asset) {
        self.id = asset.id
        self.symbol = asset.symbol
        self.name = asset.name
        self.amount = asset.amount
        self.currentPrice = asset.currentPrice
        self.savedAt = Date()
    }
    
    // MARK: - Custom Decodable (handles old and new formats)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields with fallbacks
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        amount = try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0.0
        
        // Try snake_case first, then camelCase
        if let price = try? container.decodeIfPresent(Double.self, forKey: .currentPrice) {
            currentPrice = price ?? 0.0
        } else if let price = try? container.decodeIfPresent(Double.self, forKey: .currentPriceCamel) {
            currentPrice = price ?? 0.0
        } else {
            currentPrice = 0.0
        }
        
        // Date handling: try snake_case, then camelCase, then default
        if let date = try? container.decodeIfPresent(Date.self, forKey: .savedAt) {
            savedAt = date ?? Date()
        } else if let date = try? container.decodeIfPresent(Date.self, forKey: .savedAtCamel) {
            savedAt = date ?? Date()
        } else {
            savedAt = Date()
        }
    }
    
    // MARK: - Encodable (always use snake_case for new data)
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(name, forKey: .name)
        try container.encode(amount, forKey: .amount)
        try container.encode(currentPrice, forKey: .currentPrice)
        try container.encode(savedAt, forKey: .savedAt)
    }
    
    // MARK: - Domain Conversion
    
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

// MARK: - Legacy Asset Format (for migration)

/// Legacy format that may exist in older app versions
struct LegacyAssetStorageDTO: Codable {
    let id: String?
    let symbol: String?
    let name: String?
    let amount: Double?
    let currentPrice: Double?
    let current_price: Double?
    let totalValue: Double?
    let total_value: Double?
    let iconURL: String?
    let icon_url: String?
    let savedAt: Date?
    let saved_at: Date?
    
    /// Convert to current DTO format
    func toCurrentDTO() -> AssetStorageDTO {
        AssetStorageDTO(
            id: id ?? UUID().uuidString,
            symbol: symbol ?? "",
            name: name ?? "",
            amount: amount ?? 0.0,
            currentPrice: currentPrice ?? current_price ?? 0.0,
            savedAt: savedAt ?? saved_at ?? Date()
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
