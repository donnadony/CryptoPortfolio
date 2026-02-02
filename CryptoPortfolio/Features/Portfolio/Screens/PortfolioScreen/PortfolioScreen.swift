//
//  PortfolioScreen.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import SwiftUI

struct PortfolioScreen: View {
    @Environment(\.colorScheme) var colorScheme
    // MARK: - Properties
    
    @StateObject private var viewModel = PortfolioViewModel()
    @State private var showAddSheet = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveMeshBackground()
                
                Group {
                    if viewModel.isLoading && viewModel.assets.isEmpty {
                        loadingView
                    } else if let error = viewModel.error, viewModel.assets.isEmpty {
                        errorView(error)
                    } else if viewModel.hasAssets {
                        assetsListView
                    } else {
                        emptyStateView
                    }
                }
            }
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addAssetButton
                }
            }
            .sheet(isPresented: $showAddSheet, onDismiss: {
                Task {
                    await viewModel.loadAssets()
                }
            }) {
                AddAssetScreen()
            }
            .task {
                await viewModel.loadAssets()
            }
            .refreshable {
                await viewModel.refreshAssets()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(AppTheme.Colors.primary)
            
            Text("Loading portfolio...")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            VStack(spacing: AppTheme.Spacing.lg) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.Colors.warning)
                    .symbolRenderingMode(.hierarchical)
                
                Text("Error")
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(.primary)
                
                Text(error)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    Task { await viewModel.loadAssets() }
                }) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(
                        Capsule()
                            .fill(AppTheme.Colors.warning)
                    )
                }
            }
            .padding(AppTheme.Spacing.xl)
            .liquidGlassCard()
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()
            
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 72))
                .foregroundStyle(AppTheme.Colors.secondary)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: AppTheme.Spacing.md) {
                Text("No Assets Yet")
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(.primary)
                
                Text("Start tracking your crypto portfolio by adding your first asset")
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }
            
            Button(action: { showAddSheet = true }) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add First Asset")
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
            .padding(.horizontal, AppTheme.Spacing.xl)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var assetsListView: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md, pinnedViews: [.sectionHeaders]) {
                // Portfolio Summary Card
                portfolioSummaryCard
                
                // Section Header
                HStack {
                    Text("Your Assets")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(viewModel.assets.count)")
                        .font(AppTheme.Typography.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .glassPill()
                }
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.top, AppTheme.Spacing.sm)
                
                // Asset Cards
                ForEach(viewModel.assets) { asset in
                    NavigationLink(value: Route.assetDetail(asset)) {
                        LiquidAssetRow(asset: asset)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }
    
    private var portfolioSummaryCard: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Total Value
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack {
                    Text("Total Balance")
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Circle()
                            .fill(AppTheme.Colors.success)
                            .frame(width: 6, height: 6)
                        Text("LIVE")
                            .font(AppTheme.Typography.caption2.weight(.bold))
                            .foregroundStyle(AppTheme.Colors.success)
                    }
                    .glassPill()
                }
                
                Text(viewModel.formattedTotalValue)
                    .font(AppTheme.Typography.monoTitle)
                    .foregroundStyle(.primary)
            }
            
            Divider()
                .background(.ultraThinMaterial)
            
            // Stats Row
            HStack(spacing: AppTheme.Spacing.lg) {
                // 24h Change
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("24h Change")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: viewModel.isPositiveGainLoss ? "arrow.up" : "arrow.down")
                            .font(.caption2.weight(.bold))
                        
                        Text(viewModel.formattedGainLoss)
                            .font(AppTheme.Typography.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(viewModel.isPositiveGainLoss ? AppTheme.Colors.success : AppTheme.Colors.error)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((viewModel.isPositiveGainLoss ? AppTheme.Colors.success : AppTheme.Colors.error).opacity(0.15))
                    )
                }
                
                Spacer()
                
                // Change %
                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    Text("Change %")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(viewModel.formattedGainLossPercentage)
                        .font(AppTheme.Typography.subheadline.weight(.semibold))
                        .foregroundStyle(viewModel.isPositiveGainLoss ? AppTheme.Colors.success : AppTheme.Colors.error)
                }
            }
            
            // Action Buttons
            HStack(spacing: AppTheme.Spacing.md) {
                Button(action: { showAddSheet = true }) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .font(AppTheme.Typography.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(Material.ultraThinMaterial)
                    )
                }
                
                Button(action: {
                    Task { await viewModel.refreshAssets() }
                }) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .font(AppTheme.Typography.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(AppTheme.Colors.secondary)
                    )
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .liquidGlassCard()
    }
    
    private var addAssetButton: some View {
        Button(action: { showAddSheet = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(AppTheme.Colors.primary)
        }
    }
}

// MARK: - Liquid Asset Row

private struct LiquidAssetRow: View {
    let asset: Asset
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.Colors.primary, AppTheme.Colors.primary.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Text(String(asset.symbol.prefix(1)))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Asset Info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(asset.symbol)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.primary)
                
                Text("\(asset.formattedAmount) \(asset.symbol)")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Value Info
            VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                Text(asset.formattedValue)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.primary)
                
                Text("@ \(asset.formattedPrice)")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(AppTheme.Spacing.md)
        .liquidGlassCard()
    }
}

// MARK: - Preview

#Preview {
    PortfolioScreen()
}
