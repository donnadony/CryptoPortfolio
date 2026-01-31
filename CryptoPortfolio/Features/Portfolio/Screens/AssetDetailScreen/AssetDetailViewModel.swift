//
//  AssetDetailViewModel.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import Foundation
import Combine

@MainActor
class AssetDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var asset: Asset
    @Published var marketData: MarketDataResponse?
    @Published var priceHistory: [(timestamp: Date, price: Double)] = []
    
    @Published var isLoading = false
    @Published var error: String?
    
    @Published var editAmount: String = ""
    @Published var showEditSheet = false
    
    // MARK: - Dependencies
    
    private let service: PortfolioServiceProtocol
    
    // MARK: - Initialization
    
    init(
        asset: Asset,
        service: PortfolioServiceProtocol = PortfolioService()
    ) {
        self.asset = asset
        self.service = service
        self.editAmount = String(format: "%.8f", asset.amount)
    }
    
    // MARK: - Public Methods
    
    /// Load market data and price history
    func loadDetails() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        async let marketDataTask = fetchMarketData()
        async let priceHistoryTask = fetchPriceHistory()
        
        let (_, _) = await (marketDataTask, priceHistoryTask)
    }
    
    /// Update the asset amount
    func updateAmount(_ newAmount: Double) async {
        guard newAmount > 0 else {
            error = "Amount must be greater than 0"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let updatedAsset = Asset(
                id: asset.id,
                symbol: asset.symbol,
                name: asset.name,
                amount: newAmount,
                currentPrice: asset.currentPrice
            )
            
            try await service.updateAsset(updatedAsset)
            
            self.asset = updatedAsset
            self.editAmount = String(format: "%.8f", newAmount)
            self.error = nil
            self.showEditSheet = false
        } catch {
            self.error = "Failed to update asset: \(error.localizedDescription)"
        }
    }
    
    /// Delete the asset
    func deleteAsset() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await service.deleteAsset(id: asset.id)
            error = nil
        } catch {
            self.error = "Failed to delete asset: \(error.localizedDescription)"
        }
    }
    
    /// Refresh market data
    func refreshData() async {
        await loadDetails()
    }
    
    // MARK: - Private Methods
    
    private func fetchMarketData() async {
        do {
            let data = try await service.fetchMarketData(symbol: asset.symbol)
            self.marketData = data
        } catch {
            self.error = "Failed to load market data: \(error.localizedDescription)"
        }
    }
    
    private func fetchPriceHistory() async {
        do {
            let history = try await service.fetchPriceHistory(symbol: asset.symbol, days: 30)
            self.priceHistory = history
        } catch {
            self.error = "Failed to load price history: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Computed Properties
    
    var marketCap: String {
        guard let marketData = marketData,
              let cap = marketData.marketCap else {
            return "N/A"
        }
        return String(format: "$%.2B", cap)
    }
    
    var marketCapRank: String {
        guard let marketData = marketData,
              let rank = marketData.marketCapRank else {
            return "N/A"
        }
        return "#\(rank)"
    }
    
    var priceChange24h: String {
        guard let marketData = marketData,
              let change = marketData.priceChangePercentage24h else {
            return "N/A"
        }
        let sign = change >= 0 ? "+" : ""
        return String(format: "%s%.2f%%", sign, change)
    }
    
    var isPricePositive24h: Bool {
        guard let marketData = marketData,
              let change = marketData.priceChangePercentage24h else {
            return false
        }
        return change >= 0
    }
    
    var highPrice: Double? {
        priceHistory.map { $0.price }.max()
    }
    
    var lowPrice: Double? {
        priceHistory.map { $0.price }.min()
    }
    
    var averagePrice: Double? {
        guard !priceHistory.isEmpty else { return nil }
        let sum = priceHistory.reduce(0) { $0 + $1.price }
        return sum / Double(priceHistory.count)
    }
    
    var formattedHighPrice: String {
        guard let high = highPrice else { return "N/A" }
        return String(format: "$%.2f", high)
    }
    
    var formattedLowPrice: String {
        guard let low = lowPrice else { return "N/A" }
        return String(format: "$%.2f", low)
    }
    
    var formattedAveragePrice: String {
        guard let avg = averagePrice else { return "N/A" }
        return String(format: "$%.2f", avg)
    }
}
