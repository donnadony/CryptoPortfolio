//
//  SettingsScreen.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import SwiftUI

struct SettingsScreen: View {
    // MARK: - Properties
    
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showResetAlert = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                // Currency Section
                currencySection
                
                // Theme Section
                themeSection
                
                // Notifications Section
                notificationsSection
                
                // About Section
                aboutSection
                
                // Reset Section
                resetSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.grouped)
            .alert(
                "Reset Settings",
                isPresented: $showResetAlert,
                actions: {
                    Button("Cancel", role: .cancel) {}
                    Button("Reset", role: .destructive) {
                        viewModel.resetToDefaults()
                    }
                },
                message: {
                    Text("Are you sure you want to reset all settings to their default values?")
                }
            )
        }
    }
    
    // MARK: - Sections
    
    private var currencySection: some View {
        Section {
            Picker("Currency", selection: .init(
                get: { viewModel.settings.currency },
                set: { viewModel.updateCurrency($0) }
            )) {
                ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                    HStack {
                        Text(currency)
                        Spacer()
                        Text(AppSettings.currencySymbols[currency] ?? "$")
                            .foregroundColor(.secondary)
                            .font(.headline)
                    }
                    .tag(currency)
                }
            }
            .pickerStyle(.automatic)
        } header: {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(AppTheme.Colors.primary)
                Text("Currency")
            }
        } footer: {
            Text("Select your preferred currency for displaying prices")
        }
    }
    
    private var themeSection: some View {
        Section {
            Picker("Theme", selection: .init(
                get: { viewModel.settings.theme },
                set: { viewModel.updateTheme($0) }
            )) {
                ForEach(viewModel.availableThemes, id: \.self) { theme in
                    Text(viewModel.themeNames[theme] ?? theme)
                        .tag(theme)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            HStack {
                Image(systemName: "paintpalette.fill")
                    .foregroundColor(AppTheme.Colors.secondary)
                Text("Theme")
            }
        } footer: {
            Text("Choose how the app should appear")
        }
    }
    
    private var notificationsSection: some View {
        Section {
            Toggle(
                isOn: .init(
                    get: { viewModel.settings.notificationsEnabled },
                    set: { _ in viewModel.toggleNotifications() }
                )
            ) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(AppTheme.Colors.accent)
                    Text("Notifications")
                }
            }
        } footer: {
            Text("Receive notifications about price changes and portfolio updates")
        }
    }
    
    private var aboutSection: some View {
        Section {
            // App Version
            HStack {
                Text("Version")
                    .foregroundColor(.secondary)
                Spacer()
                Text(appVersion)
                    .fontWeight(.medium)
            }
            
            // Developer Info
            HStack {
                Text("Developer")
                    .foregroundColor(.secondary)
                Spacer()
                Text("CryptoPortfolio Team")
                    .fontWeight(.medium)
            }
            
            // GitHub Link (optional)
            Link(destination: URL(string: "https://github.com")!) {
                HStack {
                    Text("GitHub")
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
        } header: {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(AppTheme.Colors.secondary)
                Text("About")
            }
        }
    }
    
    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset All Settings")
                }
            }
        } footer: {
            Text("This will reset all settings to their default values")
        }
    }
    
    // MARK: - Helper Properties
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Preview

#Preview {
    SettingsScreen()
}
