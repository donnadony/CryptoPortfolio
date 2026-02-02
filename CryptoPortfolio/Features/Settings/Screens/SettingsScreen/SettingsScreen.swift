//
//  SettingsScreen.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import SwiftUI

struct SettingsScreen: View {
    @Environment(\.colorScheme) var colorScheme
    // MARK: - Properties
    
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showResetAlert = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveMeshBackground()
                
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.lg, pinnedViews: [.sectionHeaders]) {
                        // Header
                        settingsHeader
                        
                        // Theme Section - Now with visual cards
                        themeSection
                        
                        // Currency Section
                        currencySection
                        
                        // Notifications Section
                        notificationsSection
                        
                        // About Section
                        aboutSection
                        
                        // Reset Section
                        resetSection
                        
                        // Footer
                        footerSection
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert(
                "Reset Settings",
                isPresented: $showResetAlert,
                actions: {
                    Button("Cancel", role: .cancel) {}
                    Button("Reset", role: .destructive) {
                        viewModel.resetToDefaults()
                        themeManager.setTheme(.system)
                    }
                },
                message: {
                    Text("Reset all settings to default values?")
                }
            )
        }
    }
    
    // MARK: - Header
    
    private var settingsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Preferences")
                    .font(AppTheme.Typography.title3)
                    .foregroundStyle(.primary)
                
                Text("Customize your experience")
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "gearshape.2.fill")
                .font(.system(size: 32))
                .foregroundStyle(AppTheme.Colors.primary)
                .symbolRenderingMode(.hierarchical)
        }
        .padding(AppTheme.Spacing.lg)
        .liquidGlassCard()
    }
    
    // MARK: - Theme Section
    
    private var themeSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Section Title
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "paintpalette.fill")
                    .foregroundStyle(AppTheme.Colors.secondary)
                Text("Appearance")
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.primary)
            }
            
            // Theme Cards
            HStack(spacing: AppTheme.Spacing.md) {
                ForEach(ThemeManager.Theme.allCases, id: \.self) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: themeManager.currentTheme == theme
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            themeManager.setTheme(theme)
                        }
                    }
                }
            }
            
            Text("Choose how CryptoPortfolio appears")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, AppTheme.Spacing.sm)
        }
        .padding(AppTheme.Spacing.lg)
        .liquidGlassCard()
    }
    
    // MARK: - Currency Section
    
    private var currencySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundStyle(AppTheme.Colors.primary)
                Text("Currency")
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.primary)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: AppTheme.Spacing.md) {
                ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                    CurrencyButton(
                        currency: currency,
                        symbol: AppSettings.currencySymbols[currency] ?? "$",
                        isSelected: viewModel.settings.currency == currency
                    ) {
                        viewModel.updateCurrency(currency)
                    }
                }
            }
            
            Text("Select your preferred currency")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, AppTheme.Spacing.sm)
        }
        .padding(AppTheme.Spacing.lg)
        .liquidGlassCard()
    }
    
    // MARK: - Notifications Section
    
    private var notificationsSection: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "bell.fill")
                    .foregroundStyle(AppTheme.Colors.accent)
                Text("Notifications")
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Toggle("", isOn: .init(
                get: { viewModel.settings.notificationsEnabled },
                set: { _ in viewModel.toggleNotifications() }
            ))
            .toggleStyle(SwitchToggleStyle(tint: AppTheme.Colors.accent))
            .labelsHidden()
        }
        .padding(AppTheme.Spacing.lg)
        .liquidGlassCard()
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(AppTheme.Colors.secondary)
                Text("About")
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.primary)
            }
            
            VStack(spacing: 0) {
                // Version
                AboutRow(title: "Version", value: appVersion)
                
                Divider()
                    .padding(.leading, AppTheme.Spacing.lg)
                
                // Developer
                AboutRow(title: "Developer", value: "Dony")
                
                Divider()
                    .padding(.leading, AppTheme.Spacing.lg)
                
                // GitHub
                Link(destination: URL(string: "https://github.com/donnadony")!) {
                    HStack {
                        Text("GitHub")
                            .foregroundStyle(.secondary)
                        Spacer()
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Text("@donnadony")
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.Colors.primary)
                            Image(systemName: "arrow.up.forward")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.Colors.primary)
                        }
                    }
                    .padding(AppTheme.Spacing.md)
                    .contentShape(Rectangle())
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md, style: .continuous)
                    .fill(Material.ultraThinMaterial)
            )
        }
        .padding(AppTheme.Spacing.lg)
        .liquidGlassCard()
    }
    
    // MARK: - Reset Section
    
    private var resetSection: some View {
        Button(role: .destructive) {
            showResetAlert = true
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 18, weight: .semibold))
                Text("Reset All Settings")
                    .font(AppTheme.Typography.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(AppTheme.Colors.error)
            .padding(AppTheme.Spacing.lg)
            .liquidGlassCard()
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Footer
    
    private var footerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(AppTheme.Colors.primary.opacity(0.5))
            
            Text("CryptoPortfolio")
                .font(AppTheme.Typography.footnote.weight(.medium))
                .foregroundStyle(.secondary)
            
            Text("© 2026 Dony. All rights reserved.")
                .font(AppTheme.Typography.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
    }
    
    // MARK: - Helper Properties
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Theme Card

struct ThemeCard: View {
    let theme: ThemeManager.Theme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(themeBackground)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: theme.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(themeIconColor)
                }
                
                Text(theme.displayName)
                    .font(AppTheme.Typography.caption.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                themeCardBackground
            )
        }
        .buttonStyle(.plain)
    }
    
    private var themeCardBackground: some View {
        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md, style: .continuous)
            .fill(themeCardFill)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md, style: .continuous)
                    .stroke(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.glassBorder, lineWidth: isSelected ? 2 : 0.5)
            )
    }
    
    private var themeCardFill: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(AppTheme.Colors.primary.opacity(0.15))
        } else {
            return AnyShapeStyle(Material.ultraThinMaterial)
        }
    }
    
    private var themeBackground: Color {
        switch theme {
        case .light:
            return Color.white
        case .dark:
            return Color.black
        case .system:
            return Color.gray.opacity(0.3)
        }
    }
    
    private var themeIconColor: Color {
        switch theme {
        case .light:
            return .orange
        case .dark:
            return .indigo
        case .system:
            return .gray
        }
    }
}

// MARK: - Currency Button

struct CurrencyButton: View {
    let currency: String
    let symbol: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.xs) {
                Text(symbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .primary)
                
                Text(currency)
                    .font(AppTheme.Typography.caption2.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
            }
            .frame(width: 70, height: 60)
            .background(currencyButtonBackground)
        }
        .buttonStyle(.plain)
    }
    
    private var currencyButtonBackground: some View {
        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md, style: .continuous)
            .fill(currencyButtonFill)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md, style: .continuous)
                    .stroke(isSelected ? Color.clear : AppTheme.Colors.glassBorder, lineWidth: 0.5)
            )
    }
    
    private var currencyButtonFill: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(AppTheme.Colors.primary)
        } else {
            return AnyShapeStyle(Material.ultraThinMaterial)
        }
    }
}

// MARK: - About Row

struct AboutRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .padding(AppTheme.Spacing.md)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    SettingsScreen()
}
