//
//  WatchlistService.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation
import Combine

/// Legacy WatchlistService - use WatchlistServiceImpl through DI Container instead
final class WatchlistService: WatchlistServiceProtocol, @unchecked Sendable {
    
    private let localStorage: LocalStorageProtocol
    private let watchlistKey = "crypto_watchlist"
    
    init(localStorage: LocalStorageProtocol) {
        self.localStorage = localStorage
    }
    
    func fetchItems() -> [WatchlistItem] {
        // Synchronous API - returns empty on error
        do {
            let semaphore = DispatchSemaphore(value: 0)
            var result: [WatchlistItem] = []
            
            Task {
                if let items = try? await localStorage.fetch(forKey: watchlistKey, as: [WatchlistItem].self) {
                    result = items.sorted { $0.addedAt > $1.addedAt }
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            return result
        }
    }
    
    func addItem(_ item: WatchlistItem) {
        Task {
            var items = await fetchItemsAsync()
            items.removeAll { $0.id == item.id }
            items.append(item)
            try? await localStorage.save(items, forKey: watchlistKey)
        }
    }
    
    func removeItem(id: String) {
        Task {
            var items = await fetchItemsAsync()
            items.removeAll { $0.id == id }
            try? await localStorage.save(items, forKey: watchlistKey)
        }
    }
    
    func updateAlert(id: String, price: Double?) {
        Task {
            var items = await fetchItemsAsync()
            if let index = items.firstIndex(where: { $0.id == id }) {
                items[index].alertPrice = price
                try? await localStorage.save(items, forKey: watchlistKey)
            }
        }
    }
    
    func isInWatchlist(id: String) -> Bool {
        fetchItems().contains { $0.id == id }
    }
    
    private func fetchItemsAsync() async -> [WatchlistItem] {
        (try? await localStorage.fetch(forKey: watchlistKey, as: [WatchlistItem].self)) ?? []
    }
}
