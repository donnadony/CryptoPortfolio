//
//  AssetDetailViewModel.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation
import Combine

@MainActor
final class AssetDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var asset: Asset
    @Published var marketData: MarketDataResponse?
    @Published var priceHistory: [PriceHistoryPoint] = []
    
    /// Unified view state
    @Published var state: AssetDetailViewState = .idle
    
    /// Typed error
    @Published var error: DomainError?
    
    @Published var editAmount: String = ""
    @Published var showEditSheet = false
    
    /// Loading state
    var isLoading: Bool { state.isLoading }
    
    // MARK: - Dependencies (UseCases)
    
    private let updateAssetUseCase: any UpdateAssetUseCaseProtocol
    private let deleteAssetUseCase: any DeleteAssetUseCaseProtocol
    private let portfolioFetchMarketDataUseCase: any PortfolioFetchMarketDataUseCaseProtocol
    private let fetchPriceHistoryUseCase: any FetchPriceHistoryUseCaseProtocol
    
    // MARK: - Task Management
    
    private var loadTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(
        asset: Asset,
        updateAssetUseCase: any UpdateAssetUseCaseProtocol,
        deleteAssetUseCase: any DeleteAssetUseCaseProtocol,
        portfolioFetchMarketDataUseCase: any PortfolioFetchMarketDataUseCaseProtocol,
        fetchPriceHistoryUseCase: any FetchPriceHistoryUseCaseProtocol
    ) {
        self.asset = asset
        self.updateAssetUseCase = updateAssetUseCase
        self.deleteAssetUseCase = deleteAssetUseCase
        self.portfolioFetchMarketDataUseCase = portfolioFetchMarketDataUseCase
        self.fetchPriceHistoryUseCase = fetchPriceHistoryUseCase
        self.editAmount = String(format: "%.8f", asset.amount)
    }
    
    // MARK: - Public Methods
    
    /// Load market data and price history with parallel execution
    func loadDetails() async {
        // Cancel existing load task
        loadTask?.cancel()
        
        loadTask = Task { @MainActor in
            guard !Task.isCancelled else { return }
            
            state = .loading
            error = nil
            
            do {
                // Use async let for parallel execution
                async let marketDataTask = fetchMarketData()
                async let priceHistoryTask = fetchPriceHistory()
                
                let (marketDataResult, priceHistoryResult) = await (marketDataTask, priceHistoryTask)
                
                guard !Task.isCancelled else { return }
                
                self.marketData = marketDataResult
                self.priceHistory = priceHistoryResult
                
                let detailData = AssetDetailData(
                    asset: asset,
                    marketData: marketDataResult,
                    priceHistory: priceHistoryResult
                )
                
                self.state = .loaded(detailData)
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
    
    /// Update the asset amount
    func updateAmount(_ newAmount: Double) async {
        guard newAmount > 0 else {
            error = DomainError.invalidAmount
            return
        }
        
        do {
            let updatedAsset = Asset(
                id: asset.id,
                symbol: asset.symbol,
                name: asset.name,
                amount: newAmount,
                currentPrice: asset.currentPrice
            )
            
            try await updateAssetUseCase.execute(updatedAsset)
            
            self.asset = updatedAsset
            self.editAmount = String(format: "%.8f", newAmount)
            self.error = nil
            self.showEditSheet = false
            
            // Update state
            let detailData = AssetDetailData(
                asset: updatedAsset,
                marketData: marketData,
                priceHistory: priceHistory
            )
            state = .loaded(detailData)
        } catch let domainError as DomainError {
            self.error = domainError
        } catch {
            self.error = DomainError.unknown(error.localizedDescription)
        }
    }
    
    /// Delete the asset
    func deleteAsset() async throws {
        try await deleteAssetUseCase.execute(id: asset.id)
    }
    
    /// Refresh market data
    func refreshData() async {
        await loadDetails()
    }
    
    /// Clear error state
    func clearError() {
        error = nil
        if case .error = state {
            state = .idle
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchMarketData() async -> MarketDataResponse? {
        do {
            return try await portfolioFetchMarketDataUseCase.execute(symbol: asset.symbol)
        } catch {
            // Don't fail the whole operation if market data fails
            print("⚠️ Failed to fetch market data: \(error)")
            return nil
        }
    }
    
    private func fetchPriceHistory() async -> [PriceHistoryPoint] {
        do {
            return try await fetchPriceHistoryUseCase.execute(symbol: asset.symbol, days: 30)
        } catch {
            // Don't fail the whole operation if price history fails
            print("⚠️ Failed to fetch price history: \(error)")
            return []
        }
    }
    
    // MARK: - Computed Properties
    
    var marketCap: String {
        guard let marketData = marketData,
              let cap = marketData.marketCap else {
            return "N/A"
        }
        return String(format: "$%.2fB", cap / 1_000_000_000)
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
        return String(format: "%@%.2f%%", sign, change)
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
