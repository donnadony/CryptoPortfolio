//
//  PortfolioViewModel.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation
import Combine

@MainActor
final class PortfolioViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var assets: [Asset] = []
    @Published var totalValue: Double = 0
    @Published var gainLoss: Double = 0
    @Published var gainLossPercentage: Double = 0
    
    /// Unified view state
    @Published var state: PortfolioViewState = .idle
    
    /// Typed error (replaces String? error)
    @Published var error: DomainError?
    
    /// Loading state derived from state
    var isLoading: Bool { state.isLoading }
    var isRefreshing: Bool { 
        if case .loading = state { return true }
        return false
    }
    
    // MARK: - Dependencies (UseCases)
    
    private let getAssetsUseCase: any GetAssetsUseCaseProtocol
    private let calculatePortfolioTotalUseCase: any CalculatePortfolioTotalUseCaseProtocol
    private let deleteAssetUseCase: any DeleteAssetUseCaseProtocol
    
    // MARK: - Task Management
    
    private var loadTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(
        getAssetsUseCase: any GetAssetsUseCaseProtocol,
        calculatePortfolioTotalUseCase: any CalculatePortfolioTotalUseCaseProtocol,
        deleteAssetUseCase: any DeleteAssetUseCaseProtocol
    ) {
        self.getAssetsUseCase = getAssetsUseCase
        self.calculatePortfolioTotalUseCase = calculatePortfolioTotalUseCase
        self.deleteAssetUseCase = deleteAssetUseCase
    }
    
    // MARK: - Public Methods
    
    /// Load all portfolio assets with cancellation support
    func loadAssets() async {
        // Cancel any existing load task
        loadTask?.cancel()
        
        loadTask = Task { @MainActor in
            guard !Task.isCancelled else { return }
            
            state = .loading
            error = nil
            
            do {
                let portfolioData = try await calculatePortfolioTotalUseCase.execute()
                
                guard !Task.isCancelled else { return }
                
                self.assets = portfolioData.assets
                self.totalValue = portfolioData.totalValue
                self.gainLoss = portfolioData.gainLoss
                self.gainLossPercentage = portfolioData.gainLossPercentage
                self.state = .loaded(portfolioData)
                self.error = nil
            } catch let domainError as DomainError {
                guard !Task.isCancelled else { return }
                self.state = .error(domainError)
                self.error = domainError
            } catch {
                guard !Task.isCancelled else { return }
                let wrappedError = DomainError.unknown(error.localizedDescription)
                self.state = .error(wrappedError)
                self.error = wrappedError
            }
        }
        
        await loadTask?.value
    }
    
    /// Refresh portfolio with cancellation support
    func refreshAssets() async {
        // Cancel any existing refresh task
        refreshTask?.cancel()
        
        refreshTask = Task { @MainActor in
            guard !Task.isCancelled else { return }
            
            // Keep previous data visible during refresh
            let previousState = state
            state = .loading
            error = nil
            
            do {
                let portfolioData = try await calculatePortfolioTotalUseCase.execute()
                
                guard !Task.isCancelled else { return }
                
                self.assets = portfolioData.assets
                self.totalValue = portfolioData.totalValue
                self.gainLoss = portfolioData.gainLoss
                self.gainLossPercentage = portfolioData.gainLossPercentage
                self.state = .loaded(portfolioData)
                self.error = nil
            } catch let domainError as DomainError {
                guard !Task.isCancelled else { 
                    // Restore previous state on cancel
                    self.state = previousState
                    return 
                }
                self.state = .error(domainError)
                self.error = domainError
            } catch {
                guard !Task.isCancelled else { 
                    self.state = previousState
                    return 
                }
                let wrappedError = DomainError.unknown(error.localizedDescription)
                self.state = .error(wrappedError)
                self.error = wrappedError
            }
        }
        
        await refreshTask?.value
    }
    
    /// Delete an asset from the portfolio
    func deleteAsset(_ asset: Asset) async {
        error = nil
        
        do {
            try await deleteAssetUseCase.execute(id: asset.id)
            
            // Update local state
            assets.removeAll { $0.id == asset.id }
            
            // Recalculate totals using business logic
            recalculateTotals()
            
            // Update state with new data
            let portfolioData = PortfolioData(
                assets: assets,
                totalValue: totalValue,
                gainLoss: gainLoss,
                gainLossPercentage: gainLossPercentage
            )
            state = assets.isEmpty ? .idle : .loaded(portfolioData)
            
            // Notify other views that portfolio changed
            await NotificationCenter.postPortfolioChange(userInfo: [
                "action": "delete",
                "assetId": asset.id
            ])
            
        } catch let domainError as DomainError {
            self.error = domainError
        } catch {
            self.error = DomainError.unknown(error.localizedDescription)
        }
    }
    
    /// Clear error state
    func clearError() {
        error = nil
        if case .error = state {
            state = .idle
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
        String(format: "%@$%.2f", isPositiveGainLoss ? "+" : "", abs(gainLoss))
    }
    
    var formattedGainLossPercentage: String {
        String(format: "%@%.2f%%", isPositiveGainLoss ? "+" : "", abs(gainLossPercentage))
    }
    
    // MARK: - Private Methods
    
    /// Recalculate totals from current assets
    private func recalculateTotals() {
        totalValue = assets.reduce(0) { $0 + $1.totalValue }
        // For now, we calculate gain/loss as 0 since we don't track purchase price
        // This would need historical data to be accurate
        gainLoss = 0
        gainLossPercentage = 0
    }
}
