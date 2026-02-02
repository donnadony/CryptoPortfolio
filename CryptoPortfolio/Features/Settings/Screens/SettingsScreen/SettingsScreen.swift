//
//  SettingsScreen.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import SwiftUI

struct SettingsScreen: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showError = false
    
    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.makeSettingsViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveMeshBackground()
                
                Form {
                    // Appearance Section
                    Section("Appearance") {
                        Picker("Theme", selection: Binding(
                            get: { viewModel.settings.theme },
                            set: { newValue in
                                Task {
                                    await viewModel.updateTheme(newValue)
                                }
                            }
                        )) {
                            ForEach(viewModel.availableThemes, id: \.self) { theme in
                                Text(viewModel.themeNames[theme] ?? theme)
                                    .tag(theme)
                            }
                        }
                    }
                    
                    // Currency Section
                    Section("Currency") {
                        Picker("Currency", selection: Binding(
                            get: { viewModel.settings.currency },
                            set: { newValue in
                                Task {
                                    await viewModel.updateCurrency(newValue)
                                }
                            }
                        )) {
                            ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                                Text(currency)
                                    .tag(currency)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    
                    // Notifications Section
                    Section("Notifications") {
                        Toggle("Enable Notifications", isOn: Binding(
                            get: { viewModel.settings.notificationsEnabled },
                            set: { _ in
                                Task {
                                    await viewModel.toggleNotifications()
                                }
                            }
                        ))
                    }
                    
                    // About Section
                    Section("About") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(.secondary)
                        }
                        
                        Button("Reset to Defaults") {
                            Task {
                                await viewModel.resetToDefaults()
                            }
                        }
                        .foregroundStyle(AppTheme.Colors.error)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadSettings()
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
}

// MARK: - Preview

#Preview {
    SettingsScreen()
        .withContainer()
}
