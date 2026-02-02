//
//  CryptoPortfolioApp.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import SwiftUI

@main
struct CryptoPortfolioApp: App {
    @StateObject private var container = Container.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .environmentObject(themeManager)
                .environmentObject(languageManager)
                .environment(\.container, container)
                .environment(\.locale, languageManager.currentLocale)
                .preferredColorScheme(themeManager.preferredColorScheme)
        }
    }
}
