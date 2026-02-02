//
//  AddAssetScreen.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import SwiftUI

struct AddAssetScreen: View {
    // MARK: - Properties
    
    @StateObject private var viewModel = AddAssetViewModel()
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField: FocusedField?
    
    enum FocusedField {
        case symbol
        case amount
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Symbol Input Card
                    symbolInputCard
                    
                    // Price Display Card
                    if viewModel.currentPrice > 0 {
                        priceDisplayCard
                    }
                    
                    // Amount Input Card
                    amountInputCard
                    
                    // Preview Card
                    if viewModel.isAmountValid && viewModel.currentPrice > 0 {
                        previewCard
                    }
                    
                    // Error Alert
                    if let error = viewModel.error {
                        errorAlert(error)
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Add Asset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.saveAsset()
                            if viewModel.error == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.canSave)
                    .opacity(viewModel.canSave ? 1 : 0.5)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var symbolInputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Cryptocurrency Symbol", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if viewModel.isSymbolValid {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            HStack(spacing: 12) {
                TextField("e.g., BTC, ETH, XRP", text: $viewModel.symbol)
                    .textInputAutocapitalization(.characters)
                    .focused($focusedField, equals: .symbol)
                    .onChange(of: viewModel.symbol) { _ in
                        viewModel.currentPrice = 0
                    }
                
                if viewModel.isValidating {
                    ProgressView()
                        .scaleEffect(0.8, anchor: .center)
                } else if viewModel.isSymbolValid {
                    Button(action: {
                        Task {
                            await viewModel.fetchPrice()
                        }
                    }) {
                        Text("Fetch")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            Text("Enter the crypto symbol (2-10 characters)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var priceDisplayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Current Price", systemImage: "dollarsign.circle.fill")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.symbol.isEmpty ? "---" : viewModel.symbol)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formattedCurrentPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.brandPrimary)
                }
                
                Spacer()
                
                if viewModel.isValidating {
                    ProgressView()
                        .scaleEffect(1.2, anchor: .center)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 24))
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .transition(.scale.combined(with: .opacity))
    }
    
    private var amountInputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Amount to Invest", systemImage: "bitcoinsign.circle.fill")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if viewModel.isAmountValid {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            TextField("0.00", text: $viewModel.amount)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .amount)
                .onChange(of: viewModel.amount) { _ in
                    viewModel.updateTotalValue()
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Text("How much of this asset do you want to add?")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var previewCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Summary")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Amount")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.amount)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.symbol)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formattedCurrentPrice)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            
            Divider()
            
            HStack {
                Text("Total Investment")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(viewModel.formattedTotalValue)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.brandPrimary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .transition(.scale.combined(with: .opacity))
    }
    
    private func errorAlert(_ error: String) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
                
                Text(error)
                    .font(.callout)
                    .foregroundColor(.red)
                    .lineLimit(3)
                
                Spacer()
            }
        }
        .padding(12)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Preview

#Preview {
    AddAssetScreen()
}
