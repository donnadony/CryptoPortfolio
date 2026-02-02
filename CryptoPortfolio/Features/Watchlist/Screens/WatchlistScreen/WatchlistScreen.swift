//
//  WatchlistScreen.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import SwiftUI

struct WatchlistScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: WatchlistViewModel
    @State private var showAddSheet = false
    @State private var showError = false
    
    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.makeWatchlistViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveMeshBackground()
                
                Group {
                    if viewModel.items.isEmpty {
                        emptyStateView
                    } else {
                        watchlistView
                    }
                }
            }
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppTheme.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                MarketScreen()
            }
            .task {
                await viewModel.loadItems()
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
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()
            
            Image(systemName: "star.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(AppTheme.Colors.secondary.opacity(0.5))
            
            VStack(spacing: AppTheme.Spacing.md) {
                Text("No Favorites Yet")
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(.primary)
                
                Text("Add cryptocurrencies to your watchlist to track them easily")
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }
            
            Button(action: { showAddSheet = true }) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                    Text("Browse Market")
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
    
    private var watchlistView: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                ForEach(viewModel.items) { item in
                    WatchlistCard(
                        item: item,
                        onDelete: {
                            Task {
                                await viewModel.removeItem(id: item.id)
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

// MARK: - Watchlist Card

struct WatchlistCard: View {
    let item: WatchlistItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Text(String(item.symbol.prefix(1)))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.primary)
            }
            
            // Info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(item.name)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.primary)
                
                Text(item.symbol.uppercased())
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Star indicator
            Image(systemName: "star.fill")
                .foregroundStyle(AppTheme.Colors.warning)
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.error)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(AppTheme.Colors.error.opacity(0.15))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(AppTheme.Spacing.md)
        .liquidGlassCard()
    }
}

// MARK: - Preview

#Preview {
    WatchlistScreen()
        .withContainer()
}
