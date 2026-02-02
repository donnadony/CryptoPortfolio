//
//  PortfolioScreen.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import SwiftUI

#if os(iOS)
struct PortfolioScreen: View {
    @Environment(\.container) private var container
    @StateObject private var viewModel: PortfolioViewModel
    @State private var showAddAsset = false
    @State private var assetToDelete: Asset?
    @State private var showDeleteConfirmation = false
    
    /// Tracks if we need to refresh after sheet dismissal
    @State private var needsRefreshOnAppear = false
    
    init() {
        // Use DI container to create ViewModel
        _viewModel = StateObject(wrappedValue: Container.shared.makePortfolioViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveMeshBackground()
                
                Group {
                    switch viewModel.state {
                    case .loading where viewModel.assets.isEmpty:
                        loadingView
                    case .error(let error) where viewModel.assets.isEmpty:
                        errorView(error)
                    default:
                        if viewModel.assets.isEmpty {
                            emptyStateView
                        } else {
                            portfolioView
                        }
                    }
                }
            }
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddAsset = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppTheme.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddAsset, onDismiss: {
                // Refresh portfolio when sheet is dismissed
                Task {
                    await viewModel.refreshAssets()
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
            .onReceive(NotificationCenter.default.publisher(for: .portfolioDidChange)) { _ in
                // Listen for portfolio change notifications from anywhere in the app
                Task {
                    await viewModel.refreshAssets()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
            .confirmationDialog(
                "Delete Asset?",
                isPresented: $showDeleteConfirmation,
                presenting: assetToDelete
            ) { asset in
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteAsset(asset)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: { asset in
                Text("Are you sure you want to delete \(asset.name) from your portfolio?")
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading Portfolio...")
                .font(AppTheme.Typography.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(_ error: DomainError) -> some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.Colors.warning)
            
            Text("Unable to Load Portfolio")
                .font(AppTheme.Typography.title3)
            
            Text(error.localizedDescription)
                .font(AppTheme.Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                Task {
                    await viewModel.loadAssets()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Views
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()
            
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 72))
                .foregroundStyle(AppTheme.Colors.secondary.opacity(0.5))
            
            VStack(spacing: AppTheme.Spacing.md) {
                Text("No Assets Yet")
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(.primary)
                
                Text("Add your first cryptocurrency to start tracking your portfolio")
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }
            
            Button(action: { showAddAsset = true }) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "plus")
                    Text("Add Asset")
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
    
    private var portfolioView: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                // Total Value Card
                totalValueCard
                
                // Assets List
                ForEach(viewModel.assets) { asset in
                    NavigationLink(value: Route.assetDetail(asset)) {
                        AssetRow(asset: asset)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            assetToDelete = asset
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }
    
    private var totalValueCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("Total Value")
                .font(AppTheme.Typography.subheadline)
                .foregroundStyle(.secondary)
            
            Text(viewModel.formattedTotalValue)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: viewModel.isPositiveGainLoss ? "arrow.up.right" : "arrow.down.right")
                    .foregroundStyle(viewModel.isPositiveGainLoss ? AppTheme.Colors.success : AppTheme.Colors.error)
                
                Text("\(viewModel.formattedGainLoss) (\(viewModel.formattedGainLossPercentage))")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(viewModel.isPositiveGainLoss ? AppTheme.Colors.success : AppTheme.Colors.error)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .liquidGlassCard()
    }
}

// MARK: - Asset Row

struct AssetRow: View {
    let asset: Asset
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Text(String(asset.symbol.prefix(1)))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.primary)
            }
            
            // Info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(asset.name)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.primary)
                
                Text("\(asset.formattedAmount) \(asset.symbol.uppercased())")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Value
            VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                Text(asset.formattedValue)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.primary)
                
                Text(asset.formattedPrice)
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
        .withContainer()
}
#endif
