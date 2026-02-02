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
                Label("Portfolio", systemImage: "chart.pie.fill")
            }
            
            #if os(iOS)
            // Market Tab
            NavigationStack {
                MarketScreen()
            }
            .tabItem {
                Label("Market", systemImage: "chart.bar.fill")
            }
            
            // Analytics Tab
            AnalyticsDashboardScreen()
                .tabItem {
                    Label("Analytics", systemImage: "chart.xyaxis.line")
                }
            
            // Watchlist Tab
            NavigationStack {
                WatchlistScreen()
            }
            .tabItem {
                Label("Watchlist", systemImage: "star.fill")
            }
            
            // Settings Tab
            NavigationStack {
                SettingsScreen()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            #endif
        }
        .environmentObject(router)
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.preferredColorScheme)
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
            Text("Export Analytics")
                .navigationTitle("Export")
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
}
