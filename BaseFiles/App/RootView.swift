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
            // Temporary placeholder - will add PortfolioScreen later
            Text("CryptoPortfolio")
                .font(AppTheme.Typography.largeTitle)
                .navigationTitle("Portfolio")
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
            Text("Portfolio Screen")
        case .assetDetail(let assetId):
            Text("Asset Detail: \(assetId)")
        case .addAsset:
            Text("Add Asset Screen")
        case .market:
            Text("Market Screen")
        case .settings:
            Text("Settings Screen")
        }
    }
}

#Preview {
    RootView()
}
