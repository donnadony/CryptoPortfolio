//
//  Route.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
//

import Foundation

enum Route: Hashable {
    case portfolio
    case assetDetail(assetId: String)
    case addAsset
    case market
    case settings
}
