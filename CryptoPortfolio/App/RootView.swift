//
//  RootView.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
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
            
            NavigationStack {
                MarketScreen()
            }
            .tabItem {
                Label("Market", systemImage: "chart.bar.fill")
            }
            
            NavigationStack {
                SettingsScreen()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
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
        case .market:
            MarketScreen()
        case .settings:
            SettingsScreen()
        }
    }
}

#Preview {
    RootView()
}
