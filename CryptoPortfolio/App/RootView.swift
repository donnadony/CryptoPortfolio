//
//  RootView.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = Router()
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    
    /// Force view refresh on language change
    @State private var languageRefreshId = UUID()
    
    var body: some View {
        TabView {
            // Portfolio Tab
            NavigationStack(path: $router.path) {
                PortfolioScreen()
                    .navigationDestination(for: Route.self) { route in
                        routeView(for: route)
                    }
            }
            .tabItem {
                Label(LocalizedKey.Tab.portfolio.localized, systemImage: "chart.pie.fill")
            }
            
            #if os(iOS)
            // Market Tab
            NavigationStack {
                MarketScreen()
            }
            .tabItem {
                Label(LocalizedKey.Tab.market.localized, systemImage: "chart.bar.fill")
            }
            
            // Analytics Tab
            AnalyticsDashboardScreen()
                .tabItem {
                    Label(LocalizedKey.Tab.analytics.localized, systemImage: "chart.xyaxis.line")
                }
            
            // Watchlist Tab
            NavigationStack {
                WatchlistScreen()
            }
            .tabItem {
                Label(LocalizedKey.Tab.watchlist.localized, systemImage: "star.fill")
            }
            
            // Settings Tab
            NavigationStack {
                SettingsScreen()
            }
            .tabItem {
                Label(LocalizedKey.Tab.settings.localized, systemImage: "gearshape.fill")
            }
            #endif
        }
        .id(languageRefreshId)
        .environmentObject(router)
        .environmentObject(themeManager)
        .environmentObject(languageManager)
        .environment(\.locale, languageManager.currentLocale)
        .preferredColorScheme(themeManager.preferredColorScheme)
        .onReceive(NotificationCenter.default.publisher(for: LanguageManager.languageDidChangeNotification)) { _ in
            // Force view hierarchy refresh on language change
            languageRefreshId = UUID()
        }
    }
    
    @ViewBuilder
    private func routeView(for route: Route) -> some View {
        switch route {
        #if os(iOS)
        case .portfolio:
            PortfolioScreen()
        case .assetDetail(let asset):
            AssetDetailScreen(asset: asset)
        case .addAsset:
            AddAssetScreen()
        case .market:
            MarketScreen()
        case .analytics:
            AnalyticsDashboardScreen()
        case .analyticsExport:
            Text(LocalizedKey.Analytics.export.localized)
                .navigationTitle(LocalizedKey.Analytics.export.localized)
        case .settings:
            SettingsScreen()
        #else
        case .portfolio:
            Text("Portfolio not available on this platform")
        case .assetDetail:
            Text("Asset detail not available on this platform")
        case .addAsset:
            Text("Add Asset not available on this platform")
        case .market:
            Text("Market not available on this platform")
        case .analytics, .analyticsExport:
            Text("Analytics not available on this platform")
        case .settings:
            Text("Settings not available on this platform")
        #endif
        }
    }
}

// MARK: - Preview

#Preview {
    RootView()
        .withContainer()
        .environmentObject(ThemeManager.shared)
        .environmentObject(LanguageManager.shared)
}
