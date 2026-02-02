//
//  SettingsScreen.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import SwiftUI

#if os(iOS)
struct SettingsScreen: View {
    @StateObject private var viewModel: SettingsViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var showError = false
    
    /// Force view refresh on language change
    @State private var refreshId = UUID()
    
    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.makeSettingsViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveMeshBackground()
                
                Form {
                    // Appearance Section
                    Section(LocalizedKey.Settings.appearance.localized) {
                        // Theme Picker
                        Picker(LocalizedKey.Settings.theme.localized, selection: Binding(
                            get: { viewModel.settings.theme },
                            set: { newValue in
                                Task {
                                    await viewModel.updateTheme(newValue)
                                }
                            }
                        )) {
                            ForEach(viewModel.availableThemes, id: \.self) { theme in
                                Text(localizedThemeName(theme))
                                    .tag(theme)
                            }
                        }
                        
                        // Language Picker
                        Picker(LocalizedKey.Settings.language.localized, selection: Binding(
                            get: { languageManager.currentLanguage },
                            set: { newLanguage in
                                languageManager.setLanguage(newLanguage)
                                refreshId = UUID()
                            }
                        )) {
                            ForEach(LanguageManager.Language.allCases) { language in
                                HStack {
                                    Text(language.icon)
                                    Text(language.displayName)
                                }
                                .tag(language)
                            }
                        }
                    }
                    
                    // Currency Section
                    Section(LocalizedKey.Settings.currency.localized) {
                        Picker(LocalizedKey.Settings.currency.localized, selection: Binding(
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
                    Section(LocalizedKey.Settings.notifications.localized) {
                        Toggle(LocalizedKey.Settings.enableNotifications.localized, isOn: Binding(
                            get: { viewModel.settings.notificationsEnabled },
                            set: { _ in
                                Task {
                                    await viewModel.toggleNotifications()
                                }
                            }
                        ))
                    }
                    
                    // About Section
                    Section(LocalizedKey.Settings.about.localized) {
                        HStack {
                            Text(LocalizedKey.Settings.version.localized)
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(.secondary)
                        }
                        
                        Button(LocalizedKey.Settings.resetDefaults.localized) {
                            Task {
                                await viewModel.resetToDefaults()
                                languageManager.setLanguage(.system)
                                refreshId = UUID()
                            }
                        }
                        .foregroundStyle(AppTheme.Colors.error)
                    }
                }
            }
            .id(refreshId)
            .navigationTitle(LocalizedKey.Settings.title.localized)
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadSettings()
            }
            .alert(LocalizedKey.Common.error.localized, isPresented: $showError) {
                Button(LocalizedKey.Common.ok.localized) {
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
    
    /// Get localized theme name
    private func localizedThemeName(_ theme: String) -> String {
        switch theme {
        case "light":
            return LocalizedKey.Settings.themeLight.localized
        case "dark":
            return LocalizedKey.Settings.themeDark.localized
        case "system":
            return LocalizedKey.Settings.themeSystem.localized
        default:
            return theme.capitalized
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsScreen()
        .withContainer()
        .environmentObject(LanguageManager.shared)
}
#endif
