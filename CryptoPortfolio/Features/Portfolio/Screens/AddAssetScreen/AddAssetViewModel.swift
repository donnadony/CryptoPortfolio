//
//  AddAssetViewModel.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation
import Combine

@MainActor
final class AddAssetViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var symbol: String = ""
    @Published var amount: String = ""
    @Published var currentPrice: Double = 0
    @Published var totalValue: Double = 0
    
    @Published var isLoading = false
    @Published var isValidating = false
    @Published var symbolSuggestions: [String] = []
    @Published var showSuggestions = false
    
    /// Typed error
    @Published var error: DomainError?
    
    // MARK: - Dependencies (UseCases)
    
    private let addAssetUseCase: any AddAssetUseCaseProtocol
    private let fetchPriceUseCase: any FetchPriceUseCaseProtocol
    
    // MARK: - Task Management
    
    private var priceFetchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(
        addAssetUseCase: any AddAssetUseCaseProtocol,
        fetchPriceUseCase: any FetchPriceUseCaseProtocol
    ) {
        self.addAssetUseCase = addAssetUseCase
        self.fetchPriceUseCase = fetchPriceUseCase
    }
    
    // MARK: - Public Methods
    
    /// Validate and save the asset
    func saveAsset() async -> Bool {
        guard validateInput() else { return false }
        
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            guard let amountValue = Double(amount), amountValue > 0 else {
                throw DomainError.invalidAmount
            }
            
            let asset = Asset(
                symbol: symbol.uppercased(),
                name: symbol.uppercased(),
                amount: amountValue,
                currentPrice: currentPrice
            )
            
            try await addAssetUseCase.execute(asset)
            error = nil
            return true
        } catch let domainError as DomainError {
            self.error = domainError
            return false
        } catch {
            self.error = DomainError.unknown(error.localizedDescription)
            return false
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
    
    /// Fetch current price for the entered symbol with cancellation
    func fetchPrice() async {
        // Cancel any existing price fetch task
        priceFetchTask?.cancel()
        
        guard !symbol.isEmpty else {
            error = DomainError.invalidSymbol
            return
        }
        
        priceFetchTask = Task { @MainActor in
            isValidating = true
            error = nil
            
            do {
                let price = try await fetchPriceUseCase.execute(symbol: symbol)
                
                guard !Task.isCancelled else { return }
                
                self.currentPrice = price
                self.error = nil
                self.updateTotalValue()
            } catch let domainError as DomainError {
                guard !Task.isCancelled else { return }
                self.error = domainError
                self.currentPrice = 0
            } catch {
                guard !Task.isCancelled else { return }
                self.error = DomainError.unknown(error.localizedDescription)
                self.currentPrice = 0
            }
            
            self.isValidating = false
        }
        
        await priceFetchTask?.value
    }
    
    /// Clear error state
    func clearError() {
        error = nil
    }
    
    /// Reset form
    func reset() {
        symbol = ""
        amount = ""
        currentPrice = 0
        totalValue = 0
        isLoading = false
        error = nil
    }
    
    // MARK: - Private Methods
    
    private func validateInput() -> Bool {
        error = nil
        
        guard !symbol.trimmingCharacters(in: .whitespaces).isEmpty else {
            error = DomainError.invalidSymbol
            return false
        }
        
        guard symbol.count >= 2 && symbol.count <= 10 else {
            error = DomainError.invalidSymbol
            return false
        }
        
        guard !amount.isEmpty else {
            error = DomainError.invalidAmount
            return false
        }
        
        guard let amountValue = Double(amount), amountValue > 0 else {
            error = DomainError.invalidAmount
            return false
        }
        
        guard currentPrice > 0 else {
            error = DomainError.invalidAssetData
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
