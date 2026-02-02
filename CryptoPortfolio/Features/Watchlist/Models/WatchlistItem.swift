//
//  WatchlistItem.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation

struct WatchlistItem: Codable, Identifiable, Equatable {
    let id: String
    let symbol: String
    let name: String
    let image: String?
    let addedAt: Date
    var alertPrice: Double?
    
    init(
        id: String,
        symbol: String,
        name: String,
        image: String? = nil,
        alertPrice: Double? = nil
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.image = image
        self.addedAt = Date()
        self.alertPrice = alertPrice
    }
}
