//
//  PortfolioViewModel.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import Foundation
import Combine

@MainActor
class PortfolioViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var assets: [Asset] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var error: String?
    @Published var totalValue: Double = 0
    @Published var gainLoss: Double = 0
    @Published var gainLossPercentage: Double = 0
    
    // MARK: - Dependencies
    
    private let service: PortfolioServiceProtocol
    
    // MARK: - Initialization
    
    init(service: PortfolioServiceProtocol = PortfolioService()) {
        self.service = service
    }
    
    // MARK: - Public Methods
    
    /// Load all portfolio assets
    func loadAssets() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            let summary = try await service.calculatePortfolioTotal()
            self.assets = summary.assets
            self.totalValue = summary.totalValue
            self.gainLoss = summary.gainLoss
            self.gainLossPercentage = summary.gainLossPercentage
        } catch {
            self.error = "Failed to load portfolio: \(error.localizedDescription)"
        }
    }
    
    /// Refresh portfolio (for pull-to-refresh)
    func refreshAssets() async {
        isRefreshing = true
        error = nil
        defer { isRefreshing = false }
        
        do {
            let summary = try await service.calculatePortfolioTotal()
            self.assets = summary.assets
            self.totalValue = summary.totalValue
            self.gainLoss = summary.gainLoss
            self.gainLossPercentage = summary.gainLossPercentage
        } catch {
            self.error = "Failed to refresh portfolio: \(error.localizedDescription)"
        }
    }
    
    /// Add a new asset to the portfolio
    func addAsset(symbol: String, amount: Double) async {
        guard !symbol.isEmpty, amount > 0 else {
            error = "Please enter valid symbol and amount"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch current price for the symbol
            let price = try await service.fetchPrice(symbol: symbol)
            
            let newAsset = Asset(
                symbol: symbol.uppercased(),
                name: symbol.uppercased(),
                amount: amount,
                currentPrice: price
            )
            
            try await service.addAsset(newAsset)
            
            // Refresh the portfolio
            await loadAssets()
            error = nil
        } catch {
            self.error = "Failed to add asset: \(error.localizedDescription)"
        }
    }
    
    /// Delete an asset from the portfolio
    func deleteAsset(_ asset: Asset) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await service.deleteAsset(id: asset.id)
            
            // Update local state
            assets.removeAll { $0.id == asset.id }
            
            // Recalculate totals
            totalValue = assets.reduce(0) { $0 + $1.totalValue }
            gainLoss = assets.reduce(0) { acc, asset in
                acc + (asset.totalValue - (asset.amount * asset.currentPrice))
            }
            gainLossPercentage = totalValue > 0 ? (gainLoss / totalValue) * 100 : 0
            
            error = nil
        } catch {
            self.error = "Failed to delete asset: \(error.localizedDescription)"
        }
    }
    
    /// Update an asset's amount
    func updateAsset(_ asset: Asset, newAmount: Double) async {
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
            
            // Update local state
            if let index = assets.firstIndex(where: { $0.id == asset.id }) {
                assets[index] = updatedAsset
                
                // Recalculate totals
                totalValue = assets.reduce(0) { $0 + $1.totalValue }
                gainLoss = assets.reduce(0) { acc, asset in
                    acc + (asset.totalValue - (asset.amount * asset.currentPrice))
                }
                gainLossPercentage = totalValue > 0 ? (gainLoss / totalValue) * 100 : 0
            }
            
            error = nil
        } catch {
            self.error = "Failed to update asset: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Computed Properties
    
    var hasAssets: Bool {
        !assets.isEmpty
    }
    
    var isPositiveGainLoss: Bool {
        gainLoss >= 0
    }
    
    var formattedTotalValue: String {
        String(format: "$%.2f", totalValue)
    }
    
    var formattedGainLoss: String {
        String(format: "%s$%.2f", isPositiveGainLoss ? "+" : "", abs(gainLoss))
    }
    
    var formattedGainLossPercentage: String {
        String(format: "%s%.2f%%", isPositiveGainLoss ? "+" : "", abs(gainLossPercentage))
    }
}
