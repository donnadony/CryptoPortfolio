//
//  WatchlistServiceProtocol.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation

protocol WatchlistServiceProtocol: Sendable {
    func fetchItems() -> [WatchlistItem]
    func addItem(_ item: WatchlistItem)
    func removeItem(id: String)
    func updateAlert(id: String, price: Double?)
    func isInWatchlist(id: String) -> Bool
}
