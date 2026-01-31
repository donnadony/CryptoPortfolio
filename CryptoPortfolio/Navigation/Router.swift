//
//  Router.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import SwiftUI
import Combine

@MainActor
class Router: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to route: Route) {
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
