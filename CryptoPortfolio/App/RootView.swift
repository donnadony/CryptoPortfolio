//
//  RootView.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = Router()
    
    var body: some View {
        TabView {
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
            NavigationStack {
                MarketScreen()
            }
            .tabItem {
                Label("Market", systemImage: "chart.bar.fill")
            }
            #endif
            
            #if os(iOS)
            NavigationStack {
                WatchlistScreen()
            }
            .tabItem {
                Label("Watchlist", systemImage: "star.fill")
            }
            
            #endif
            #if os(iOS)
            NavigationStack {
                SettingsScreen()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            #endif
        }
        .environmentObject(router)
    }
    
    @ViewBuilder
    private func routeView(for route: Route) -> some View {
        switch route {
        case .portfolio:
            PortfolioScreen()
        case .assetDetail(let asset):
            AssetDetailScreen(asset: asset)
        case .addAsset:
            AddAssetScreen()
        #if os(iOS)
        case .market:
            MarketScreen()
        #else
        case .market:
            Text("Market not available on this platform")
        #endif
        #if os(iOS)
        case .settings:
            SettingsScreen()
        #else
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
}
