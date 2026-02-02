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
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .environmentObject(themeManager)
                .environment(\.container, container)
                .preferredColorScheme(themeManager.preferredColorScheme)
        }
    }
}
