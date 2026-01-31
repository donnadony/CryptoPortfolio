//
//  MarketScreen.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import SwiftUI

struct MarketScreen: View {
    // MARK: - Properties
    
    @StateObject private var viewModel = MarketViewModel()
    @State private var showAddSheet = false
    @State private var selectedSymbol = ""
    @State private var selectedName = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.cryptocurrencies.isEmpty {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error)
                } else if viewModel.isEmpty {
                    emptyStateView
                } else {
                    marketListView
                }
            }
            .navigationTitle("Market")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search cryptocurrencies"
            )
            .refreshable {
                await viewModel.loadMarketData()
            }
            .toolbar {
                if !viewModel.searchText.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: viewModel.clearSearch) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
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
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ProgressView()
                .scaleEffect(1.5, anchor: .center)
            
            Text("Loading market data...")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.error)
            
            Text("Oops!")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(error)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    await viewModel.loadMarketData()
                }
            }) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(AppTheme.Typography.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(AppTheme.Colors.primary)
                .cornerRadius(AppTheme.CornerRadius.md)
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 64))
                .foregroundColor(AppTheme.Colors.secondary)
            
            Text("No Cryptocurrencies")
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("Pull to refresh and get market data")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
    }
    
    private var marketListView: some View {
        VStack(spacing: 0) {
            if viewModel.displayedCryptocurrencies.isEmpty && !viewModel.searchText.isEmpty {
                noSearchResultsView
            } else {
                List {
                    Section(header: marketHeaderView) {
                        ForEach(viewModel.displayedCryptocurrencies) { crypto in
                            cryptoRow(crypto)
                        }
                    }
                }
                .listStyle(.plain)
                .background(AppTheme.Colors.background)
            }
        }
    }
    
    private var marketHeaderView: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Top Cryptocurrencies")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("\(viewModel.displayedCryptocurrencies.count) coins by market cap")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            if viewModel.isSearching {
                ProgressView()
                    .scaleEffect(0.8, anchor: .center)
            }
        }
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.background)
    }
    
    private func cryptoRow(_ crypto: CryptoMarket) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Rank and icon
            VStack(alignment: .center, spacing: AppTheme.Spacing.xs) {
                if let rank = crypto.marketCapRank {
                    Text("#\(rank)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                if let imageUrl = crypto.image, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                        case .loading:
                            ProgressView()
                                .frame(width: 32, height: 32)
                        case .empty, .failure:
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(AppTheme.Colors.primary)
                        @unknown default:
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                    }
                } else {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .frame(width: 40)
            
            // Crypto info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Text(crypto.name)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(crypto.symbol.uppercased())
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(AppTheme.Colors.secondaryBackground)
                        .cornerRadius(AppTheme.CornerRadius.sm)
                }
                
                if let marketCap = crypto.formattedMarketCap {
                    Text("Market Cap: \(marketCap)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            // Price and change
            VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                Text(crypto.formattedPrice)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                if let priceChange = crypto.formattedPriceChange {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: crypto.isPositiveChange ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption2.bold())
                        
                        Text(priceChange)
                            .font(AppTheme.Typography.caption)
                    }
                    .foregroundColor(crypto.isPositiveChange ? AppTheme.Colors.success : AppTheme.Colors.error)
                }
            }
            
            // Add button
            Button(action: {
                selectedSymbol = crypto.symbol
                selectedName = crypto.name
                showAddSheet = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.secondary)
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .padding(.vertical, AppTheme.Spacing.sm)
        .listRowBackground(AppTheme.Colors.background)
        .listRowSeparator(.hidden)
    }
    
    private var noSearchResultsView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text("No results for \"\(viewModel.searchText)\"")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("Try searching with a different name or symbol")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
    }
    
    private var addToPortfolioSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Add to Portfolio")) {
                    HStack {
                        Text("Symbol")
                        Spacer()
                        Text(selectedSymbol.uppercased())
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(selectedName)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                
                Section(
                    header: Text("Amount"),
                    footer: Text("Enter the amount you want to add to your portfolio")
                ) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        TextField("0.00", text: .constant(""))
                            .font(AppTheme.Typography.body)
                            .keyboardType(.decimalPad)
                        
                        Text(selectedSymbol.uppercased())
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                
                Section {
                    Button(action: {
                        showAddSheet = false
                    }) {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Add to Portfolio")
                        }
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(AppTheme.CornerRadius.md)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Add to Portfolio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showAddSheet = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MarketScreen()
}
