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
        NavigationStack(path: $router.path) {
            PortfolioScreen()
                .navigationDestination(for: Route.self) { route in
                    routeView(for: route)
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
            AssetDetailScreen(asset: asset, viewModel: <#PortfolioViewModel#>)
        case .addAsset:
            AddAssetScreen()
        case .market:
            Text("Market Screen - Coming Soon")
        case .settings:
            Text("Settings Screen - Coming Soon")
        }
    }
}

#Preview {
    RootView()
}
