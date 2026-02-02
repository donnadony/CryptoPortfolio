//
//  PortfolioRouter.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 2/1/26.
//

import SwiftUI
import Combine

@MainActor
final class PortfolioRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to route: PortfolioRoute) {
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

enum PortfolioRoute: Hashable {
    case assetDetail(assetId: String)
    case addTransaction(assetId: String?)
    case transactionHistory(assetId: String)
}

extension View {
    func portfolioNavigationDestinations(router: PortfolioRouter) -> some View {
        self.navigationDestination(for: PortfolioRoute.self) { route in
            switch route {
            case .assetDetail(let assetId):
                Text("Asset: \(assetId)")
                    .navigationTitle("Asset Details")
                
            case .addTransaction(let assetId):
                Text(assetId.map { "Add Transaction for \($0)" } ?? "Add Transaction")
                    .navigationTitle("New Transaction")
                
            case .transactionHistory(let assetId):
                Text("History for \(assetId)")
                    .navigationTitle("Transactions")
            }
        }
    }
}
