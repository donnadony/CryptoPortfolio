//
//  AddAssetViewModel.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import Foundation

@MainActor
class AddAssetViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var symbol: String = ""
    @Published var amount: String = ""
    @Published var currentPrice: Double = 0
    @Published var totalValue: Double = 0
    
    @Published var isLoading = false
    @Published var isValidating = false
    @Published var error: String?
    
    @Published var symbolSuggestions: [String] = []
    @Published var showSuggestions = false
    
    // MARK: - Dependencies
    
    private let service: PortfolioServiceProtocol
    
    // MARK: - Initialization
    
    init(service: PortfolioServiceProtocol = PortfolioService()) {
        self.service = service
    }
    
    // MARK: - Public Methods
    
    /// Validate and save the asset
    func saveAsset() async {
        guard validateInput() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let amount = Double(amount), amount > 0 else {
                error = "Invalid amount"
                return
            }
            
            let asset = Asset(
                symbol: symbol.uppercased(),
                name: symbol.uppercased(),
                amount: amount,
                currentPrice: currentPrice
            )
            
            try await service.addAsset(asset)
            error = nil
        } catch {
            self.error = "Failed to save asset: \(error.localizedDescription)"
        }
    }
    
    /// Update total value based on current price and amount
    func updateTotalValue() {
        guard let amountValue = Double(amount) else {
            totalValue = 0
            return
        }
        totalValue = amountValue * currentPrice
    }
    
    /// Fetch current price for the entered symbol
    func fetchPrice() async {
        guard !symbol.isEmpty else {
            error = "Please enter a symbol"
            return
        }
        
        isValidating = true
        defer { isValidating = false }
        
        do {
            currentPrice = try await service.fetchPrice(symbol: symbol)
            error = nil
            updateTotalValue()
        } catch {
            self.error = "Could not fetch price for \(symbol)"
            currentPrice = 0
        }
    }
    
    // MARK: - Private Methods
    
    private func validateInput() -> Bool {
        error = nil
        
        guard !symbol.trimmingCharacters(in: .whitespaces).isEmpty else {
            error = "Symbol is required"
            return false
        }
        
        guard symbol.count >= 2 && symbol.count <= 10 else {
            error = "Symbol must be between 2 and 10 characters"
            return false
        }
        
        guard !amount.isEmpty else {
            error = "Amount is required"
            return false
        }
        
        guard let amountValue = Double(amount), amountValue > 0 else {
            error = "Amount must be greater than 0"
            return false
        }
        
        guard currentPrice > 0 else {
            error = "Could not fetch price for this symbol"
            return false
        }
        
        return true
    }
    
    // MARK: - Computed Properties
    
    var isSymbolValid: Bool {
        symbol.count >= 2 && symbol.count <= 10
    }
    
    var isAmountValid: Bool {
        guard let amount = Double(amount) else { return false }
        return amount > 0
    }
    
    var canSave: Bool {
        isSymbolValid && isAmountValid && currentPrice > 0 && !isLoading
    }
    
    var formattedCurrentPrice: String {
        String(format: "$%.2f", currentPrice)
    }
    
    var formattedTotalValue: String {
        String(format: "$%.2f", totalValue)
    }
}
