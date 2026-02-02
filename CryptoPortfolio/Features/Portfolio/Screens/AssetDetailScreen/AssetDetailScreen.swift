//
//  AssetDetailScreen.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import SwiftUI

struct AssetDetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AssetDetailViewModel
    @State private var showDeleteConfirmation = false
    @State private var showError = false
    
    let asset: Asset
    
    init(asset: Asset) {
        self.asset = asset
        _viewModel = StateObject(wrappedValue: Container.shared.makeAssetDetailViewModel(asset: asset))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Header
                headerSection
                
                // Price Info
                priceSection
                
                // Stats Grid
                statsSection
                
                // Price History
                priceHistorySection
                
                // Actions
                actionsSection
            }
            .padding(AppTheme.Spacing.lg)
        }
        .background(AdaptiveMeshBackground())
        .navigationTitle(viewModel.asset.symbol.uppercased())
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(AppTheme.Colors.error)
                }
            }
        }
        .confirmationDialog(
            "Delete Asset?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel.deleteAsset()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \(viewModel.asset.name) from your portfolio?")
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
        .task {
            await viewModel.loadDetails()
        }
    }
    
    // MARK: - Views
    
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text(viewModel.asset.name)
                .font(AppTheme.Typography.title)
                .foregroundStyle(.primary)
            
            Text(viewModel.asset.formattedValue)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text("\(viewModel.asset.formattedAmount) \(viewModel.asset.symbol.uppercased())")
                .font(AppTheme.Typography.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.xl)
        .liquidGlassCard()
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Market Data")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(.primary)
            
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("24h Change")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(viewModel.priceChange24h)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundStyle(viewModel.isPricePositive24h ? AppTheme.Colors.success : AppTheme.Colors.error)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    Text("Market Cap Rank")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(viewModel.marketCapRank)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .liquidGlassCard()
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Statistics")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTheme.Spacing.md) {
                StatCard(title: "High (30d)", value: viewModel.formattedHighPrice)
                StatCard(title: "Low (30d)", value: viewModel.formattedLowPrice)
                StatCard(title: "Average (30d)", value: viewModel.formattedAveragePrice)
                StatCard(title: "Market Cap", value: viewModel.marketCap)
            }
        }
    }
    
    private var priceHistorySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Price History (30 Days)")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(.primary)
            
            if viewModel.priceHistory.isEmpty {
                ContentUnavailableView {
                    Label("No Data", systemImage: "chart.line.uptrend.xyaxis")
                } description: {
                    Text("Price history is not available")
                }
                .frame(height: 200)
            } else {
                SimplePriceChart(data: viewModel.priceHistory)
                    .frame(height: 200)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .liquidGlassCard()
    }
    
    private var actionsSection: some View {
        Button(action: {
            showDeleteConfirmation = true
        }) {
            HStack {
                Image(systemName: "trash")
                Text("Remove from Portfolio")
            }
            .font(AppTheme.Typography.headline)
            .foregroundColor(AppTheme.Colors.error)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .stroke(AppTheme.Colors.error, lineWidth: 2)
            )
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(AppTheme.Typography.subheadline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.md)
        .background(Color(.systemGray6))
        .cornerRadius(AppTheme.CornerRadius.md)
    }
}

// MARK: - Simple Price Chart

struct SimplePriceChart: View {
    let data: [PriceHistoryPoint]
    
    var body: some View {
        GeometryReader { geometry in
            if let minPrice = data.map({ $0.price }).min(),
               let maxPrice = data.map({ $0.price }).max(),
               maxPrice > minPrice {
                
                let width = geometry.size.width
                let height = geometry.size.height
                let priceRange = maxPrice - minPrice
                
                Path { path in
                    for (index, point) in data.enumerated() {
                        let x = CGFloat(index) / CGFloat(data.count - 1) * width
                        let y = height - ((point.price - minPrice) / priceRange) * height
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(AppTheme.Colors.primary, lineWidth: 2)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AssetDetailScreen(
            asset: Asset(
                symbol: "BTC",
                name: "Bitcoin",
                amount: 0.5,
                currentPrice: 45000
            )
        )
    }
    .withContainer()
}
