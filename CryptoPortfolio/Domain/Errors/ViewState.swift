//
//  ViewState.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - View State

/// Unified state enum for view state management
enum ViewState<T: Equatable>: Equatable {
    case idle
    case loading
    case loaded(T)
    case error(DomainError)
    
    // MARK: - Computed Properties
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var isLoaded: Bool {
        if case .loaded = self { return true }
        return false
    }
    
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
    
    var value: T? {
        if case .loaded(let data) = self { return data }
        return nil
    }
    
    var error: DomainError? {
        if case .error(let error) = self { return error }
        return nil
    }
    
    // MARK: - State Transitions
    
    mutating func startLoading() {
        self = .loading
    }
    
    mutating func finishLoading(with data: T) {
        self = .loaded(data)
    }
    
    mutating func fail(with error: DomainError) {
        self = .error(error)
    }
    
    mutating func reset() {
        self = .idle
    }
}

// MARK: - Empty State (for operations without return value)

struct EmptyState: Equatable {}

// MARK: - Specialized View States

typealias PortfolioViewState = ViewState<PortfolioData>
typealias MarketViewState = ViewState<[CryptoMarket]>
typealias WatchlistViewState = ViewState<[WatchlistItem]>
typealias AssetDetailViewState = ViewState<AssetDetailData>

// MARK: - Data Structures

/// Data structure for Portfolio view
struct PortfolioData: Equatable {
    let assets: [Asset]
    let totalValue: Double
    let gainLoss: Double
    let gainLossPercentage: Double
}

/// Price history data point
struct PriceHistoryPoint: Equatable, Sendable {
    let timestamp: Date
    let price: Double
}

/// Data structure for Asset Detail view
struct AssetDetailData: Equatable {
    let asset: Asset
    let marketData: MarketDataResponse?
    let priceHistory: [PriceHistoryPoint]
}
