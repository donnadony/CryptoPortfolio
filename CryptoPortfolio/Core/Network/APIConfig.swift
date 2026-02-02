//
//  APIConfig.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation

struct APIConfig {
    // MARK: - CoinGecko API
    static let baseURL = "https://api.coingecko.com/api/v3"
    
    // MARK: - Request Timeout
    static let requestTimeout: TimeInterval = 30
    
    // MARK: - Endpoints
    struct Endpoints {
        // Price endpoints
        static let simplePrice = "/simple/price"
        static let coinsMarkets = "/coins/markets"
        
        // Chart data
        static func marketChart(coinId: String) -> String {
            "/coins/\(coinId)/market_chart"
        }
        
        // Coin details
        static func coinDetail(coinId: String) -> String {
            "/coins/\(coinId)"
        }
    }
}
