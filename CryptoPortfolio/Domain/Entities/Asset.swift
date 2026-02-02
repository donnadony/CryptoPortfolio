//
//  Asset.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

/// Domain entity representing a cryptocurrency asset in the portfolio
/// Supports full Codable with ISO8601 date handling and URL string conversion
struct Asset: Identifiable, Equatable, Hashable, Sendable {
    
    // MARK: - Properties
    
    let id: String
    let symbol: String
    let name: String
    let amount: Double
    let currentPrice: Double
    let totalValue: Double
    let iconURL: URL?
    let priceChangePercentage24h: Double?
    let marketCap: Double?
    let lastUpdated: Date?
    
    // MARK: - Initialization
    
    init(
        id: String = UUID().uuidString,
        symbol: String,
        name: String,
        amount: Double,
        currentPrice: Double,
        totalValue: Double? = nil,
        iconURL: URL? = nil,
        priceChangePercentage24h: Double? = nil,
        marketCap: Double? = nil,
        lastUpdated: Date? = nil
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.amount = amount
        self.currentPrice = currentPrice
        self.totalValue = totalValue ?? (amount * currentPrice)
        self.iconURL = iconURL
        self.priceChangePercentage24h = priceChangePercentage24h
        self.marketCap = marketCap
        self.lastUpdated = lastUpdated
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
    
    var formattedPriceChange: String? {
        guard let change = priceChangePercentage24h else { return nil }
        let prefix = change >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", change))%"
    }
    
    var isPriceChangePositive: Bool {
        (priceChangePercentage24h ?? 0) >= 0
    }
}

// MARK: - Codable

extension Asset: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case amount
        case currentPrice = "current_price"
        case totalValue = "total_value"
        case iconURL = "icon_url"
        case image  // Alternative key for icon
        case priceChangePercentage24h = "price_change_percentage_24h"
        case marketCap = "market_cap"
        case lastUpdated = "last_updated"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields with fallbacks
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        amount = try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0.0
        currentPrice = try container.decodeIfPresent(Double.self, forKey: .currentPrice) ?? 0.0
        
        // Computed field with fallback
        let decodedTotalValue = try container.decodeIfPresent(Double.self, forKey: .totalValue)
        totalValue = decodedTotalValue ?? (amount * currentPrice)
        
        // URL handling: try icon_url first, then image, support both URL and String
        iconURL = Self.decodeURL(from: container, keys: [.iconURL, .image])
        
        // Optional numeric fields
        priceChangePercentage24h = try container.decodeIfPresent(Double.self, forKey: .priceChangePercentage24h)
        marketCap = try container.decodeIfPresent(Double.self, forKey: .marketCap)
        
        // Date handling with ISO8601 (with and without fractional seconds)
        lastUpdated = Self.decodeISO8601Date(from: container, forKey: .lastUpdated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(name, forKey: .name)
        try container.encode(amount, forKey: .amount)
        try container.encode(currentPrice, forKey: .currentPrice)
        try container.encode(totalValue, forKey: .totalValue)
        try container.encodeIfPresent(iconURL?.absoluteString, forKey: .iconURL)
        try container.encodeIfPresent(priceChangePercentage24h, forKey: .priceChangePercentage24h)
        try container.encodeIfPresent(marketCap, forKey: .marketCap)
        
        // Encode date as ISO8601 string
        if let date = lastUpdated {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            try container.encode(formatter.string(from: date), forKey: .lastUpdated)
        }
    }
    
    // MARK: - Private Helpers
    
    /// Decode URL from multiple possible keys, handling both URL and String types
    private static func decodeURL(from container: KeyedDecodingContainer<CodingKeys>, keys: [CodingKeys]) -> URL? {
        for key in keys {
            // Try decoding as URL directly
            if let url = try? container.decodeIfPresent(URL.self, forKey: key) {
                return url
            }
            // Try decoding as String and converting
            if let urlString = try? container.decodeIfPresent(String.self, forKey: key),
               !urlString.isEmpty,
               let url = URL(string: urlString) {
                return url
            }
        }
        return nil
    }
    
    /// Decode ISO8601 date with support for fractional seconds and without
    private static func decodeISO8601Date(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> Date? {
        // Try decoding as Date directly (if decoder has date strategy)
        if let date = try? container.decodeIfPresent(Date.self, forKey: key) {
            return date
        }
        
        // Try decoding as String and parsing
        guard let dateString = try? container.decodeIfPresent(String.self, forKey: key),
              !dateString.isEmpty else {
            return nil
        }
        
        // Try ISO8601 with fractional seconds first
        let formatterWithFractional = ISO8601DateFormatter()
        formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatterWithFractional.date(from: dateString) {
            return date
        }
        
        // Try ISO8601 without fractional seconds
        let formatterWithoutFractional = ISO8601DateFormatter()
        formatterWithoutFractional.formatOptions = [.withInternetDateTime]
        if let date = formatterWithoutFractional.date(from: dateString) {
            return date
        }
        
        // Try common date formats as fallback
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let fallbackFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        for format in fallbackFormats {
            fallbackFormatter.dateFormat = format
            if let date = fallbackFormatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
}

// MARK: - Factory Methods

extension Asset {
    
    /// Create Asset from market API response
    static func fromMarketData(
        id: String,
        symbol: String,
        name: String,
        amount: Double,
        currentPrice: Double,
        iconURLString: String?,
        priceChangePercentage24h: Double?,
        marketCap: Double?,
        lastUpdatedString: String?
    ) -> Asset {
        let iconURL: URL? = iconURLString.flatMap { URL(string: $0) }
        
        var lastUpdated: Date?
        if let dateString = lastUpdatedString {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            lastUpdated = formatter.date(from: dateString)
            
            if lastUpdated == nil {
                formatter.formatOptions = [.withInternetDateTime]
                lastUpdated = formatter.date(from: dateString)
            }
        }
        
        return Asset(
            id: id,
            symbol: symbol,
            name: name,
            amount: amount,
            currentPrice: currentPrice,
            iconURL: iconURL,
            priceChangePercentage24h: priceChangePercentage24h,
            marketCap: marketCap,
            lastUpdated: lastUpdated
        )
    }
    
    /// Create a mock Asset for previews
    static func mock(
        id: String = "bitcoin",
        symbol: String = "BTC",
        name: String = "Bitcoin",
        amount: Double = 1.5,
        currentPrice: Double = 45000.0
    ) -> Asset {
        Asset(
            id: id,
            symbol: symbol,
            name: name,
            amount: amount,
            currentPrice: currentPrice
        )
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
