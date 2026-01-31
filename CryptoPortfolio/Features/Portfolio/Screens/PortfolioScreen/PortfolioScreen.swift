//
//  PortfolioScreen.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import SwiftUI

struct PortfolioScreen: View {
    // MARK: - Properties
    
    @StateObject private var viewModel = PortfolioViewModel()
    @State private var showAddSheet = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
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
        .navigationTitle("Portfolio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                addAssetButton
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddAssetSheet(
                isPresented: $showAddSheet,
                onAdd: { symbol, amount in
                    Task {
                        await viewModel.addAsset(symbol: symbol, amount: amount)
                    }
                }
            )
        }
        .task {
            await viewModel.loadAssets()
        }
        .refreshable {
            await viewModel.refreshAssets()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5, anchor: .center)
            Text("Loading your portfolio...")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(error)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    await viewModel.loadAssets()
                }
            }) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Assets Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Start tracking your cryptocurrency portfolio by adding your first asset")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { showAddSheet = true }) {
                Label("Add First Asset", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "#F7931A"))
            
            Spacer()
        }
        .padding()
    }
    
    private var assetsListView: some View {
        List {
            // Portfolio Summary Section
            Section {
                portfolioSummaryCard
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            
            // Assets Section
            if !viewModel.assets.isEmpty {
                Section("Holdings") {
                    ForEach(viewModel.assets) { asset in
                        NavigationLink(value: Route.assetDetail(asset)) {
                            AssetRowView(asset: asset)
                        }
                    }
                    .onDelete { indexSet in
                        Task {
                            for index in indexSet {
                                await viewModel.deleteAsset(viewModel.assets[index])
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if let error = viewModel.error {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.orange)
                        
                        Text(error)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.systemOrange).opacity(0.1))
                    .cornerRadius(8)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    private var portfolioSummaryCard: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Value")
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                Text(viewModel.formattedTotalValue)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("24h Change")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.isPositiveGainLoss ? "arrow.up.right" : "arrow.down.left")
                            .font(.caption)
                        
                        Text(viewModel.formattedGainLoss)
                            .font(.headline)
                    }
                    .foregroundColor(viewModel.isPositiveGainLoss ? .green : .red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Change %")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formattedGainLossPercentage)
                        .font(.headline)
                        .foregroundColor(viewModel.isPositiveGainLoss ? .green : .red)
                }
            }
            
            HStack(spacing: 12) {
                Button(action: { showAddSheet = true }) {
                    Label("Add Asset", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    Task {
                        await viewModel.refreshAssets()
                    }
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var addAssetButton: some View {
        Button(action: { showAddSheet = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 20))
        }
    }
}

// MARK: - Asset Row View

private struct AssetRowView: View {
    let asset: Asset
    
    var body: some View {
        HStack(spacing: 12) {
            // Symbol Icon
            VStack(alignment: .center, spacing: 0) {
                Text(String(asset.symbol.prefix(1)))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40)
            .background(Color(hex: "#F7931A"))
            .cornerRadius(8)
            
            // Asset Info
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.symbol)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(asset.formattedAmount) \(asset.symbol)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Value Info
            VStack(alignment: .trailing, spacing: 4) {
                Text(asset.formattedValue)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("@ \(asset.formattedPrice)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Asset Sheet

private struct AddAssetSheet: View {
    @Binding var isPresented: Bool
    let onAdd: (String, Double) -> Void
    
    @State private var symbol = ""
    @State private var amount = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Asset Details") {
                    TextField("Symbol (e.g., BTC, ETH)", text: $symbol)
                        .textInputAutocapitalization(.characters)
                        .onChange(of: symbol) { newValue in
                            symbol = newValue.uppercased()
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
            .navigationTitle("Add Asset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        resetForm()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if validateInput() {
                            if let amount = Double(amount) {
                                onAdd(symbol, amount)
                                isPresented = false
                                resetForm()
                            }
                        }
                    }
                    .disabled(symbol.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    private func validateInput() -> Bool {
        guard !symbol.isEmpty else {
            errorMessage = "Please enter a symbol"
            showError = true
            return false
        }
        
        guard !amount.isEmpty else {
            errorMessage = "Please enter an amount"
            showError = true
            return false
        }
        
        guard let amountValue = Double(amount), amountValue > 0 else {
            errorMessage = "Amount must be greater than 0"
            showError = true
            return false
        }
        
        return true
    }
    
    private func resetForm() {
        symbol = ""
        amount = ""
        showError = false
        errorMessage = ""
    }
}

// MARK: - Preview

#Preview {
    PortfolioScreen()
}
