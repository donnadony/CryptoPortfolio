//
//  AnalyticsRouter.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 2/1/26.
//

import SwiftUI
import Combine

@MainActor
final class AnalyticsRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to route: AnalyticsRoute) {
        path.append(route)
    }
    
    func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
}

enum AnalyticsRoute: Hashable {
    case assetDetail(assetId: String)
    case export
}

extension View {
    func analyticsNavigationDestinations(router: AnalyticsRouter) -> some View {
        self.navigationDestination(for: AnalyticsRoute.self) { route in
            switch route {
            case .assetDetail(let assetId):
                Text("Asset: \(assetId)")
                    .navigationTitle("Asset Details")
                
            case .export:
                Text("Export Data")
                    .navigationTitle("Export")
            }
        }
    }
}
