//
//  AddAssetScreen.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import SwiftUI

#if os(iOS)
struct AddAssetScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddAssetViewModel
    @State private var showError = false
    
    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.makeAddAssetViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveMeshBackground()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // Symbol Input
                        symbolSection
                        
                        // Amount Input
                        amountSection
                        
                        // Price Display
                        priceSection
                        
                        // Total Value
                        totalValueSection
                        
                        Spacer()
                        
                        // Save Button
                        saveButton
                    }
                    .padding(AppTheme.Spacing.lg)
                }
            }
            .navigationTitle(LocalizedKey.AddAsset.title.localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedKey.Common.cancel.localized) {
                        dismiss()
                    }
                }
            }
            .alert(LocalizedKey.Common.error.localized, isPresented: $showError) {
                Button(LocalizedKey.Common.ok.localized) {}
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
    
    // MARK: - Views
    
    private var symbolSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(LocalizedKey.AddAsset.cryptocurrency.localized)
                .font(AppTheme.Typography.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                TextField(LocalizedKey.AddAsset.symbolPlaceholder.localized, text: $viewModel.symbol)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                
                Button(action: {
                    Task {
                        await viewModel.fetchPrice()
                    }
                }) {
                    if viewModel.isValidating {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text(LocalizedKey.AddAsset.fetchPrice.localized)
                            .font(AppTheme.Typography.subheadline)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.symbol.isEmpty || viewModel.isValidating)
            }
        }
    }
    
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(LocalizedKey.AddAsset.amount.localized)
                .font(AppTheme.Typography.subheadline)
                .foregroundStyle(.secondary)
            
            TextField("0.00", text: $viewModel.amount)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .onChange(of: viewModel.amount) { _, _ in
                    viewModel.updateTotalValue()
                }
        }
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(LocalizedKey.AddAsset.currentPrice.localized)
                .font(AppTheme.Typography.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Text(viewModel.formattedCurrentPrice)
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(viewModel.currentPrice > 0 ? .primary : .secondary)
                
                Spacer()
                
                if viewModel.currentPrice > 0 {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.success)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(Color(.systemGray6))
            .cornerRadius(AppTheme.CornerRadius.md)
        }
    }
    
    private var totalValueSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(LocalizedKey.AddAsset.totalValue.localized)
                .font(AppTheme.Typography.subheadline)
                .foregroundStyle(.secondary)
            
            Text(viewModel.formattedTotalValue)
                .font(AppTheme.Typography.title2)
                .foregroundStyle(.primary)
                .padding(AppTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(AppTheme.CornerRadius.md)
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            Task {
                let success = await viewModel.saveAsset()
                if success {
                    dismiss()
                }
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(LocalizedKey.AddAsset.addToPortfolio.localized)
                }
            }
            .font(AppTheme.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                Capsule()
                    .fill(viewModel.canSave ? AppTheme.Colors.primary : AppTheme.Colors.secondary.opacity(0.3))
            )
        }
        .disabled(!viewModel.canSave)
    }
}

// MARK: - Preview

#Preview {
    AddAssetScreen()
        .withContainer()
        .environmentObject(LanguageManager.shared)
}
#endif
