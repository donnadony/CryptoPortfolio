//
//  Benchmark.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 2/1/26.
//

import Foundation

enum AvailableBenchmark: String, CaseIterable, Identifiable, Codable, Sendable {
    case bitcoin = "BTC"
    case ethereum = "ETH"
    case sp500 = "SP500"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
}

struct ExportResult: Equatable, Sendable {
    let format: String
    let recordCount: Int
    let fileURL: URL
    let exportDate: Date
}

struct PortfolioHolding: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let assetId: String
    let symbol: String
    let name: String
    let amount: Double
    let averageCost: Double
    let currentPrice: Double
    
    var marketValue: Double { amount * currentPrice }
    var costBasis: Double { amount * averageCost }
    var unrealizedPnL: Double { marketValue - costBasis }
}
