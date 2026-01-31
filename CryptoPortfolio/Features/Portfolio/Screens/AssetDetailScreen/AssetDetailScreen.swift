//
//  AssetDetailScreen.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import SwiftUI

struct AssetDetailScreen: View {
    // MARK: - Properties
    
    @StateObject private var detailViewModel: AssetDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false
    
    init(asset: Asset) {
        _detailViewModel = StateObject(wrappedValue: AssetDetailViewModel(asset: asset))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if detailViewModel.isLoading {
                loadingView
            } else {
                scrollableContent
            }
        }
        .navigationTitle(detailViewModel.asset.symbol)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showEditSheet = true }) {
                        Label("Edit Amount", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                        Label("Delete Asset", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditAssetSheet(
                asset: detailViewModel.asset,
                isPresented: $showEditSheet,
                onSave: { newAmount in
                    Task {
                        await detailViewModel.updateAmount(newAmount)
                    }
                }
            )
        }
        .confirmationDialog(
            "Delete Asset",
            isPresented: $showDeleteConfirmation,
            presenting: detailViewModel.asset
        ) { asset in
            Button("Delete", role: .destructive) {
                Task {
                    await detailViewModel.deleteAsset()
                    if detailViewModel.error == nil {
                        dismiss()
                    }
                }
            }
        } message: { asset in
            Text("Are you sure you want to delete \(asset.symbol)? This action cannot be undone.")
        }
        .refreshable {
            await detailViewModel.refreshData()
        }
        .task {
            await detailViewModel.loadDetails()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5, anchor: .center)
            Text("Loading details...")
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }
    
    private var scrollableContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header Card
                assetHeaderCard
                
                // Error Alert
                if let error = detailViewModel.error {
                    errorCard(error)
                }
                
                // Holdings Info
                holdingsCard
                
                // Market Data
                if let marketData = detailViewModel.marketData {
                    marketDataCard(marketData)
                }
                
                // Price Statistics
                if !detailViewModel.priceHistory.isEmpty {
                    priceStatisticsCard
                }
                
                // Price Chart Placeholder
                if !detailViewModel.priceHistory.isEmpty {
                    priceChartCard
                }
                
                Spacer(minLength: 20)
            }
            .padding(16)
        }
    }
    
    private var assetHeaderCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(detailViewModel.asset.symbol)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(detailViewModel.asset.name)
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 0) {
                    Text(String(detailViewModel.asset.symbol.prefix(1)))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 50)
                .background(Color(hex: "#F7931A"))
                .cornerRadius(10)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Current Price")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(detailViewModel.asset.formattedPrice)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Holdings")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(detailViewModel.asset.formattedAmount)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Total Value")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(detailViewModel.asset.formattedValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#F7931A"))
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func errorCard(_ error: String) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 18))
                
                Text(error)
                    .font(.callout)
                    .foregroundColor(.orange)
                
                Spacer()
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var holdingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Holdings Summary", systemImage: "chart.pie.fill")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { showEditSheet = true }) {
                    Label("Edit", systemImage: "pencil.circle.fill")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Amount")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(detailViewModel.asset.formattedAmount)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Price per Unit")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(detailViewModel.asset.formattedPrice)
                        .fontWeight(.semibold)
                }
                
                Divider()
                
                HStack {
                    Text("Total Investment")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(detailViewModel.asset.formattedValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#F7931A"))
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func marketDataCard(_ marketData: MarketDataResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Market Data", systemImage: "chart.bar.fill")
                .font(.headline)
                .foregroundColor(.primary)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Market Cap Rank")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(detailViewModel.marketCapRank)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Market Cap")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(detailViewModel.marketCap)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("24h Change")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: detailViewModel.isPricePositive24h ? "arrow.up.right" : "arrow.down.left")
                            .font(.caption)
                        
                        Text(detailViewModel.priceChange24h)
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(detailViewModel.isPricePositive24h ? .green : .red)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var priceStatisticsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("30-Day Statistics", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
                .foregroundColor(.primary)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("High")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(detailViewModel.formattedHighPrice)
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Low")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(detailViewModel.formattedLowPrice)
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Average")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(detailViewModel.formattedAveragePrice)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var priceChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Price History (30 Days)", systemImage: "chart.line.xaxis")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Simplified chart representation
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(0..<detailViewModel.priceHistory.count, id: \.self) { index in
                        let price = detailViewModel.priceHistory[index].price
                        let minPrice = detailViewModel.lowPrice ?? 0
                        let maxPrice = detailViewModel.highPrice ?? 1
                        let normalizedHeight = (price - minPrice) / (maxPrice - minPrice) * 100
                        
                        VStack(spacing: 0) {
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 1)
                                .fill(price >= (detailViewModel.averagePrice ?? 0) ? Color.green : Color.red)
                                .frame(height: CGFloat(normalizedHeight))
                        }
                        .frame(height: 60)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Edit Asset Sheet

private struct EditAssetSheet: View {
    let asset: Asset
    @Binding var isPresented: Bool
    let onSave: (Double) -> Void
    
    @State private var amount: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Asset Details") {
                    HStack {
                        Text("Symbol")
                        Spacer()
                        Text(asset.symbol)
                            .fontWeight(.semibold)
                    }
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                if showError {
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            
                            Text(errorMessage)
                                .font(.callout)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Edit Amount")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if validateAndSave() {
                            isPresented = false
                        }
                    }
                    .disabled(amount.isEmpty)
                }
            }
            .onAppear {
                amount = String(format: "%.8f", asset.amount)
            }
        }
    }
    
    private func validateAndSave() -> Bool {
        guard let newAmount = Double(amount), newAmount > 0 else {
            errorMessage = "Amount must be greater than 0"
            showError = true
            return false
        }
        
        onSave(newAmount)
        return true
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
            ),
            viewModel: PortfolioViewModel()
        )
    }
}
