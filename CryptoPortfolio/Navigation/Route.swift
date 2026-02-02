//
//  Route.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation

enum Route: Hashable, Equatable {
    
    case portfolio
    case assetDetail(Asset)
    case addAsset
    case market
    case settings
    
}
