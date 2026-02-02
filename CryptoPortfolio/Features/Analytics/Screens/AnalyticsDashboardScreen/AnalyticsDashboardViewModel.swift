//
//  AnalyticsDashboardViewModel.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Analytics Timeframe

enum AnalyticsTimeframe: String, CaseIterable, Sendable {

    case day = "24h"
    case week = "7d"
    case month = "30d"
    case year = "1y"
    case all = "all"

    var displayName: String {
        switch self {
        case .day: return "Last 24 Hours"
        case .week: return "Last 7 Days"
        case .month: return "Last 30 Days"
        case .year: return "Last Year"
        case .all: return "All Time"
        }
    }
    
    var localizedDisplayName: String {
        switch self {
        case .day: return LocalizedKey.Analytics.last24Hours.localized
        case .week: return LocalizedKey.Analytics.last7Days.localized
        case .month: return LocalizedKey.Analytics.last30Days.localized
        case .year: return LocalizedKey.Analytics.lastYear.localized
        case .all: return LocalizedKey.Analytics.allTime.localized
        }
    }
    
    var shortName: String { rawValue.uppercased() }
    
    var localizedShortName: String {
        switch self {
        case .day: return LocalizedKey.Analytics.day.localized
        case .week: return LocalizedKey.Analytics.week.localized
        case .month: return LocalizedKey.Analytics.month.localized
        case .year: return LocalizedKey.Analytics.year.localized
        case .all: return LocalizedKey.Analytics.all.localized
        }
    }
}

// MARK: - Asset Allocation

struct AssetAllocation: Identifiable, Equatable, Sendable {
    let id: String
    let symbol: String
    let name: String
    let value: Double
    let percentage: Double
    let color: Color
    
    var formattedPercentage: String {
        String(format: "%.1f%%", percentage)
    }
}

// MARK: - Top Performer

struct TopPerformer: Identifiable, Equatable, Sendable {
    let id: String
    let symbol: String
    let name: String
    let priceChange: Double
    
    var isPositive: Bool { priceChange >= 0 }
    
    var formattedChange: String {
        let prefix = priceChange >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", priceChange))%"
    }
}

// MARK: - ViewModel

@MainActor
final class AnalyticsDashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var state: ViewState<AnalyticsData> = .idle
    @Published var selectedTimeframe: AnalyticsTimeframe = .week
    @Published var error: DomainError?
    
    // Computed from state
    @Published private(set) var allocations: [AssetAllocation] = []
    @Published private(set) var topPerformers: [TopPerformer] = []
    @Published private(set) var totalReturn: Double = 0
    @Published private(set) var dailyChange: Double = 0
    
    // MARK: - Dependencies
    
    private let getAssetsUseCase: any GetAssetsUseCaseProtocol
    private let calculatePortfolioTotalUseCase: any CalculatePortfolioTotalUseCaseProtocol
    
    // MARK: - Task Management
    
    private var loadTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(
        getAssetsUseCase: any GetAssetsUseCaseProtocol,
        calculatePortfolioTotalUseCase: any CalculatePortfolioTotalUseCaseProtocol
    ) {
        self.getAssetsUseCase = getAssetsUseCase
        self.calculatePortfolioTotalUseCase = calculatePortfolioTotalUseCase
    }
    
    // MARK: - Computed Properties
    
    var isTotalReturnPositive: Bool { totalReturn >= 0 }
    var is24hChangePositive: Bool { dailyChange >= 0 }
    
    var formattedTotalReturn: String {
        let prefix = totalReturn >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", totalReturn))%"
    }
    
    var formatted24hChange: String {
        let prefix = dailyChange >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", dailyChange))%"
    }
    
    // MARK: - Public Methods
    
    func loadAnalytics() async {
        loadTask?.cancel()
        
        loadTask = Task { @MainActor in
            state = .loading
            error = nil
            
            do {
                let assets = try await getAssetsUseCase.execute()
                
                guard !Task.isCancelled else { return }
                
                // Calculate allocations
                let totalValue = assets.reduce(0) { $0 + $1.totalValue }
                let colors: [Color] = [
                    AppTheme.Colors.primary,
                    AppTheme.Colors.success,
                    AppTheme.Colors.warning,
                    AppTheme.Colors.info,
                    AppTheme.Colors.error,
                    .purple,
                    .orange,
                    .cyan
                ]
                
                allocations = assets.enumerated().map { index, asset in
                    let percentage = totalValue > 0 ? (asset.totalValue / totalValue) * 100 : 0
                    return AssetAllocation(
                        id: asset.id,
                        symbol: asset.symbol.uppercased(),
                        name: asset.name,
                        value: asset.totalValue,
                        percentage: percentage,
                        color: colors[index % colors.count]
                    )
                }
                .sorted { $0.percentage > $1.percentage }
                
                // Calculate top performers
                topPerformers = assets
                    .compactMap { asset -> TopPerformer? in
                        guard let change = asset.priceChangePercentage24h else { return nil }
                        return TopPerformer(
                            id: asset.id,
                            symbol: asset.symbol.uppercased(),
                            name: asset.name,
                            priceChange: change
                        )
                    }
                    .sorted { $0.priceChange > $1.priceChange }
                    .prefix(5)
                    .map { $0 }
                
                // Calculate daily change (weighted average)
                if totalValue > 0 {
                    dailyChange = assets.reduce(0) { result, asset in
                        let weight = asset.totalValue / totalValue
                        let change = asset.priceChangePercentage24h ?? 0
                        return result + (weight * change)
                    }
                } else {
                    dailyChange = 0
                }
                
                // Mock total return for demo (would come from historical data)
                totalReturn = dailyChange * 7 // Simplified
                
                let analyticsData = AnalyticsData(
                    assets: assets,
                    totalValue: totalValue,
                    allocations: allocations,
                    topPerformers: topPerformers,
                    totalReturn: totalReturn,
                    dailyChange: dailyChange
                )
                
                state = .loaded(analyticsData)
                
            } catch let domainError as DomainError {
                guard !Task.isCancelled else { return }
                state = .error(domainError)
                self.error = domainError
            } catch {
                guard !Task.isCancelled else { return }
                let wrappedError = DomainError.unknown(error.localizedDescription)
                state = .error(wrappedError)
                self.error = wrappedError
            }
        }
        
        await loadTask?.value
    }
    
    func selectTimeframe(_ timeframe: AnalyticsTimeframe) {
        selectedTimeframe = timeframe
        // In production, this would reload data for the selected timeframe
    }
    
    func clearError() {
        error = nil
        if case .error = state {
            state = .idle
        }
    }
}

// MARK: - Analytics Data

struct AnalyticsData: Equatable {
    let assets: [Asset]
    let totalValue: Double
    let allocations: [AssetAllocation]
    let topPerformers: [TopPerformer]
    let totalReturn: Double
    let dailyChange: Double
}
