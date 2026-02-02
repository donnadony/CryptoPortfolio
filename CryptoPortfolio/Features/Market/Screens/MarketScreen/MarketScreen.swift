//
//  MarketScreen.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import SwiftUI

struct MarketScreen: View {
    @StateObject private var viewModel: MarketViewModel
    @State private var showError = false
    
    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.makeMarketViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveMeshBackground()
                
                Group {
                    if viewModel.cryptocurrencies.isEmpty && viewModel.isLoading {
                        loadingView
                    } else if viewModel.cryptocurrencies.isEmpty {
                        emptyView
                    } else {
                        marketListView
                    }
                }
            }
            .navigationTitle("Market")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search cryptocurrencies"
            )
            .task {
                await viewModel.loadMarketData()
            }
            .refreshable {
                await viewModel.loadMarketData()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
            .onChange(of: viewModel.error) { _, newError in
                showError = newError != nil
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ProgressView()
                .controlSize(.large)
            Text("Loading market data...")
                .font(AppTheme.Typography.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "chart.bar")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No market data available")
                .font(AppTheme.Typography.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var marketListView: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                ForEach(viewModel.displayedCryptocurrencies) { crypto in
                    MarketRow(
                        crypto: crypto,
                        isInWatchlist: viewModel.isInWatchlist(id: crypto.id),
                        onToggleWatchlist: {
                            Task {
                                _ = await viewModel.toggleWatchlist(crypto: crypto)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }
}

// MARK: - Market Row

struct MarketRow: View {
    let crypto: CryptoMarket
    let isInWatchlist: Bool
    let onToggleWatchlist: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Rank
            if let rank = crypto.marketCapRank {
                Text("\(rank)")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 32)
            }
            
            // Icon
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Text(String(crypto.symbol.prefix(1)).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.primary)
            }
            
            // Info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(crypto.name)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.primary)
                
                Text(crypto.symbol.uppercased())
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Price Info
            VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                Text(crypto.formattedPrice)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.primary)
                
                if let change = crypto.formattedPriceChange {
                    Text(change)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(crypto.isPositiveChange ? AppTheme.Colors.success : AppTheme.Colors.error)
                }
            }
            
            // Watchlist Button
            Button(action: onToggleWatchlist) {
                Image(systemName: isInWatchlist ? "star.fill" : "star")
                    .foregroundStyle(isInWatchlist ? AppTheme.Colors.warning : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(AppTheme.Spacing.md)
        .liquidGlassCard()
    }
}

// MARK: - Preview

#Preview {
    MarketScreen()
        .withContainer()
}
