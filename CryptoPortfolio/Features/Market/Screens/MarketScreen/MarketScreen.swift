//
//  MarketScreen.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import SwiftUI

// MARK: - Market Screen

struct MarketScreen: View {
    @Environment(\.colorScheme) var colorScheme
    // MARK: - Properties
    
    @StateObject private var viewModel = MarketViewModel()
    @State private var showAddSheet = false
    @State private var selectedSymbol = ""
    @State private var selectedName = ""
    
    // Toast
    @State private var showToast = false
    @State private var toastMessage = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic gradient background
                AdaptiveMeshBackground()
                
                Group {
                    if viewModel.isLoading && viewModel.cryptocurrencies.isEmpty {
                        loadingView
                    } else if let error = viewModel.error, viewModel.cryptocurrencies.isEmpty {
                        errorView(error)
                    } else if viewModel.isEmpty {
                        emptyStateView
                    } else {
                        marketListView
                    }
                }
                
                // Rate Limit Banner (floating)
                if viewModel.isRateLimited {
                    rateLimitBanner
                }
                
                // Toast
                if showToast {
                    VStack {
                        Spacer()
                        Text(toastMessage)
                            .font(AppTheme.Typography.callout.weight(.medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.8))
                            )
                            .padding(.bottom, AppTheme.Spacing.xl)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(100)
                }
            }
            .navigationTitle("Market")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: viewModel.isRateLimited ? "Wait..." : "Search crypto..."
            )
            .disabled(viewModel.isSearchDisabled)
            .refreshable {
                if !viewModel.isRateLimited {
                    await viewModel.loadMarketData()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.searchText.isEmpty && !viewModel.isRateLimited {
                        Button(action: viewModel.clearSearch) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .disabled(viewModel.isRateLimited)
                    }
                }
            }
            .task {
                await viewModel.loadMarketData()
            }
            .sheet(isPresented: $showAddSheet) {
                addToPortfolioSheet
            }
        }
    }
    
    // MARK: - Rate Limit Banner
    
    private var rateLimitBanner: some View {
        VStack {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "timer")
                    .font(.title3)
                    .foregroundStyle(AppTheme.Colors.warning)
                
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("Rate Limited")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(.primary)
                    
                    if let countdown = viewModel.retryCountdown {
                        Text("Retry in \(countdown)s")
                            .font(AppTheme.Typography.callout)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
                
                Spacer()
                
                // Small countdown ring
                if let countdown = viewModel.retryCountdown {
                    ZStack {
                        Circle()
                            .stroke(AppTheme.Colors.warning.opacity(0.3), lineWidth: 3)
                            .frame(width: 36, height: 36)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(countdown) / 60.0)
                            .stroke(AppTheme.Colors.warning, lineWidth: 3)
                            .frame(width: 36, height: 36)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: countdown)
                        
                        Text("\(countdown)")
                            .font(AppTheme.Typography.caption2.weight(.bold))
                            .foregroundStyle(AppTheme.Colors.warning)
                    }
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md, style: .continuous)
                    .fill(AppTheme.Colors.warning.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md, style: .continuous)
                            .stroke(AppTheme.Colors.warning.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.sm)
            
            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(50)
        .allowsHitTesting(false) // Let touches pass through
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(AppTheme.Colors.primary)
            
            Text("Loading market...")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            VStack(spacing: AppTheme.Spacing.lg) {
                Image(systemName: viewModel.isRateLimited ? "timer" : "exclamationmark.triangle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(viewModel.isRateLimited ? AppTheme.Colors.warning : AppTheme.Colors.error)
                    .symbolRenderingMode(.hierarchical)
                
                Text(viewModel.isRateLimited ? "Rate Limited" : "Oops!")
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(.primary)
                
                if viewModel.isRateLimited, let countdown = viewModel.retryCountdown {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text("Too many requests")
                            .font(AppTheme.Typography.body)
                            .foregroundStyle(.secondary)
                        
                        ZStack {
                            Circle()
                                .stroke(AppTheme.Colors.warning.opacity(0.3), lineWidth: 4)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(countdown) / 60.0)
                                .stroke(AppTheme.Colors.warning, lineWidth: 4)
                                .frame(width: 80, height: 80)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 1), value: countdown)
                            
                            Text("\(countdown)")
                                .font(AppTheme.Typography.monoTitle)
                                .foregroundStyle(AppTheme.Colors.warning)
                        }
                        
                        Text("seconds remaining")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(.tertiary)
                    }
                } else {
                    Text(error)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    Task { await viewModel.loadMarketData() }
                }) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "arrow.clockwise")
                        Text(viewModel.isRateLimited ? "Retry Now" : "Try Again")
                    }
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(
                        Capsule()
                            .fill(viewModel.canRetry ? AppTheme.Colors.primary : AppTheme.Colors.neutralGray)
                    )
                }
                .disabled(!viewModel.canRetry)
                .opacity(viewModel.canRetry ? 1 : 0.6)
            }
            .padding(AppTheme.Spacing.xl)
            .liquidGlassCard()
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.Colors.secondary)
                .symbolRenderingMode(.hierarchical)
            
            Text("No Data")
                .font(AppTheme.Typography.title2)
                .foregroundStyle(.primary)
            
            Text("Pull down to refresh")
                .font(AppTheme.Typography.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var marketListView: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                // Header (no pinned to avoid title collision)
                marketStatsHeader
                    .padding(.top, AppTheme.Spacing.sm)
                
                if viewModel.displayedCryptocurrencies.isEmpty && !viewModel.searchText.isEmpty {
                    noSearchResultsView
                } else {
                    // Crypto Cards
                    ForEach(viewModel.displayedCryptocurrencies) { crypto in
                        CryptoCard(
                            crypto: crypto,
                            onAdd: {
                                selectedSymbol = crypto.symbol
                                selectedName = crypto.name
                                showAddSheet = true
                            },
                            onToggleWatchlist: {
                                let message = viewModel.toggleWatchlist(crypto: crypto)
                                showToast(message: message)
                            },
                            isInWatchlist: viewModel.isInWatchlist(id: crypto.id)
                        )
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.sm)
        }
    }
    
    private var marketStatsHeader: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Live indicator
            HStack(spacing: AppTheme.Spacing.xs) {
                Circle()
                    .fill(AppTheme.Colors.success)
                    .frame(width: 8, height: 8)
                
                Text("LIVE")
                    .font(AppTheme.Typography.caption2.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.success)
            }
            .glassPill()
            
            Spacer()
            
            Text("\(viewModel.displayedCryptocurrencies.count) coins")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
                .glassPill()
            
            if viewModel.isSearching {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
    }
    
    private var noSearchResultsView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No results")
                .font(AppTheme.Typography.title3)
                .foregroundStyle(.primary)
            
            Text("Try a different search")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .liquidGlassCard()
    }
    
    private var addToPortfolioSheet: some View {
        NavigationStack {
            ZStack {
                AdaptiveMeshBackground()
                
                Form {
                    Section {
                        HStack {
                            Text("Asset")
                            Spacer()
                            Text(selectedSymbol.uppercased())
                                .font(AppTheme.Typography.headline)
                                .foregroundStyle(AppTheme.Colors.primary)
                        }
                        
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(selectedName)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md, style: .continuous)
                            .fill(Material.ultraThinMaterial)
                    )
                    
                    Section(header: Text("Amount")) {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            TextField("0.00", text: .constant(""))
                                .font(AppTheme.Typography.monoHeadline)
                                .keyboardType(.decimalPad)
                            
                            Text(selectedSymbol.uppercased())
                                .font(AppTheme.Typography.body)
                                .foregroundStyle(.secondary)
                                .glassPill()
                        }
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md, style: .continuous)
                            .fill(Material.ultraThinMaterial)
                    )
                    
                    Section {
                        Button(action: { showAddSheet = false }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add to Portfolio")
                            }
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .background(
                                Capsule()
                                    .fill(AppTheme.Colors.primary)
                            )
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Asset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showAddSheet = false
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
    }
    
    // MARK: - Toast
    
    private func showToast(message: String) {
        toastMessage = message
        withAnimation {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
}

// MARK: - Crypto Card Component

struct CryptoCard: View {
    let crypto: CryptoMarket
    let onAdd: () -> Void
    let onToggleWatchlist: () -> Void
    let isInWatchlist: Bool
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Icon and Rank
            ZStack {
                // Glass circle background
                Circle()
                    .fill(Material.ultraThinMaterial)
                    .frame(width: 52, height: 52)
                
                if let imageUrl = crypto.image, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                        case .empty, .failure:
                            fallbackIcon
                        @unknown default:
                            fallbackIcon
                        }
                    }
                } else {
                    fallbackIcon
                }
                
                // Rank badge
                if let rank = crypto.marketCapRank {
                    Text("#\(rank)")
                        .font(AppTheme.Typography.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(AppTheme.Colors.secondary.opacity(0.9))
                        )
                        .offset(x: 18, y: -18)
                }
            }
            
            // Crypto Info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Text(crypto.name)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(.primary)
                    
                    Text(crypto.symbol.uppercased())
                        .font(AppTheme.Typography.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Material.ultraThinMaterial)
                        )
                }
                
                if let marketCap = crypto.formattedMarketCap {
                    Text("MCap: \(marketCap)")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Price and Change
            VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                Text(crypto.formattedPrice)
                    .font(AppTheme.Typography.monoHeadline)
                    .foregroundStyle(.primary)
                
                if let priceChange = crypto.formattedPriceChange {
                    HStack(spacing: 2) {
                        Image(systemName: crypto.isPositiveChange ? "arrow.up" : "arrow.down")
                            .font(.caption2.weight(.bold))
                        
                        Text(priceChange)
                            .font(AppTheme.Typography.caption.weight(.semibold))
                    }
                    .foregroundStyle(crypto.isPositiveChange ? AppTheme.Colors.success : AppTheme.Colors.error)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((crypto.isPositiveChange ? AppTheme.Colors.success : AppTheme.Colors.error).opacity(0.15))
                    )
                }
            }
            
            // Action Buttons
            HStack(spacing: AppTheme.Spacing.sm) {
                // Watchlist Button
                Button(action: onToggleWatchlist) {
                    Image(systemName: isInWatchlist ? "star.fill" : "star")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isInWatchlist ? AppTheme.Colors.warning : AppTheme.Colors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(watchlistButtonBackground)
                }
                .buttonStyle(.plain)
                
                // Add Button
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(AppTheme.Colors.secondary)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppTheme.Spacing.md)
        .liquidGlassCard()
    }
    
    private var watchlistButtonBackground: some View {
        Circle()
            .fill(watchlistButtonFill)
    }
    
    private var watchlistButtonFill: some ShapeStyle {
        if isInWatchlist {
            return AnyShapeStyle(AppTheme.Colors.warning.opacity(0.15))
        } else {
            return AnyShapeStyle(Material.ultraThinMaterial)
        }
    }
    
    private var fallbackIcon: some View {
        Image(systemName: "bitcoinsign.circle.fill")
            .font(.system(size: 32))
            .foregroundStyle(AppTheme.Colors.primary)
    }
}

// MARK: - Preview

#Preview {
    MarketScreen()
}
