//
//  ThemeManager.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import SwiftUI
import Combine

/// Theme manager for controlling light/dark mode across the app
/// Uses @Published preferredColorScheme to propagate changes through SwiftUI
@MainActor
final class ThemeManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = ThemeManager()
    
    // MARK: - Persisted Theme
    
    @AppStorage("app_theme") private var storedTheme: String = "system"
    
    // MARK: - Published Properties
    
    /// Current theme selection
    @Published var currentTheme: Theme = .system
    
    /// Color scheme to apply to the app - nil means follow system
    @Published var preferredColorScheme: ColorScheme?
    
    // MARK: - Theme Enum
    
    enum Theme: String, CaseIterable, Sendable {
        case light = "light"
        case dark = "dark"
        case system = "system"
        
        var displayName: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"
            case .system: return "System"
            }
        }
        
        var icon: String {
            switch self {
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            case .system: return "gear"
            }
        }
        
        /// Converts to SwiftUI ColorScheme (nil = system default)
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        let theme = Theme(rawValue: storedTheme) ?? .system
        currentTheme = theme
        preferredColorScheme = theme.colorScheme
    }
    
    // MARK: - Public Methods
    
    /// Set the app theme and persist the selection
    func setTheme(_ theme: Theme) {
        currentTheme = theme
        storedTheme = theme.rawValue
        preferredColorScheme = theme.colorScheme
    }
    
    /// Toggle between light and dark (skipping system)
    func toggleLightDark() {
        switch currentTheme {
        case .light:
            setTheme(.dark)
        case .dark, .system:
            setTheme(.light)
        }
    }
    
    /// Cycle through all themes: system → light → dark → system
    func cycleTheme() {
        switch currentTheme {
        case .system:
            setTheme(.light)
        case .light:
            setTheme(.dark)
        case .dark:
            setTheme(.system)
        }
    }
}

// MARK: - View Extension for Theme Application

extension View {
    /// Apply the ThemeManager's preferred color scheme to this view
    func applyTheme(from themeManager: ThemeManager) -> some View {
        self.preferredColorScheme(themeManager.preferredColorScheme)
    }
}
