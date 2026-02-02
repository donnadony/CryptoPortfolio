//
//  WatchlistService.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation
import Combine

final class WatchlistService: WatchlistServiceProtocol, @unchecked Sendable {
    static let shared = WatchlistService()
    
    private let userDefaults: UserDefaults
    private let watchlistKey = "crypto_watchlist"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func fetchItems() -> [WatchlistItem] {
        guard let data = userDefaults.data(forKey: watchlistKey),
              let items = try? JSONDecoder().decode([WatchlistItem].self, from: data) else {
            return []
        }
        return items.sorted { $0.addedAt > $1.addedAt }
    }
    
    func addItem(_ item: WatchlistItem) {
        var items = fetchItems()
        items.removeAll { $0.id == item.id }
        items.append(item)
        saveItems(items)
    }
    
    func removeItem(id: String) {
        var items = fetchItems()
        items.removeAll { $0.id == id }
        saveItems(items)
    }
    
    func updateAlert(id: String, price: Double?) {
        var items = fetchItems()
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].alertPrice = price
            saveItems(items)
        }
    }
    
    func isInWatchlist(id: String) -> Bool {
        fetchItems().contains { $0.id == id }
    }
    
    private func saveItems(_ items: [WatchlistItem]) {
        if let data = try? JSONEncoder().encode(items) {
            userDefaults.set(data, forKey: watchlistKey)
        }
    }
}
