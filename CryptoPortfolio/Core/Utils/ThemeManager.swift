//
//  ThemeManager.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import SwiftUI
import Combine

/// Theme manager for controlling light/dark mode across the app
@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("app_theme") private var storedTheme: String = "system"
    
    @Published var currentTheme: Theme = .system
    
    enum Theme: String, CaseIterable {
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
    }
    
    private init() {
        currentTheme = Theme(rawValue: storedTheme) ?? .system
        applyTheme(currentTheme)
    }
    
    func setTheme(_ theme: Theme) {
        currentTheme = theme
        storedTheme = theme.rawValue
        applyTheme(theme)
    }
    
    private func applyTheme(_ theme: Theme) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        switch theme {
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        case .system:
            window.overrideUserInterfaceStyle = .unspecified
        }
    }
}
