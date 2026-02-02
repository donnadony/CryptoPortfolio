//
//  WatchlistLocalDataSource.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Protocol

protocol WatchlistLocalDataSourceProtocol: Sendable {
    func fetchItems() async throws -> [WatchlistItem]
    func saveItems(_ items: [WatchlistItem]) async throws
    func addItem(_ item: WatchlistItem) async throws
    func removeItem(id: String) async throws
    func updateAlert(id: String, price: Double?) async throws
    func isInWatchlist(id: String) async throws -> Bool
}

// MARK: - Implementation

final class WatchlistLocalDataSource: WatchlistLocalDataSourceProtocol, @unchecked Sendable {
    
    private let localStorage: LocalStorageProtocol
    private let watchlistKey = "crypto_watchlist"
    
    init(localStorage: LocalStorageProtocol) {
        self.localStorage = localStorage
    }
    
    func fetchItems() async throws -> [WatchlistItem] {
        let items = try await localStorage.fetch(forKey: watchlistKey, as: [WatchlistItem].self)
        return (items ?? []).sorted { $0.addedAt > $1.addedAt }
    }
    
    func saveItems(_ items: [WatchlistItem]) async throws {
        try await localStorage.save(items, forKey: watchlistKey)
    }
    
    func addItem(_ item: WatchlistItem) async throws {
        var items = try await fetchItems()
        
        // Remove if already exists
        items.removeAll { $0.id == item.id }
        
        // Add new item
        items.append(item)
        
        try await localStorage.save(items, forKey: watchlistKey)
    }
    
    func removeItem(id: String) async throws {
        var items = try await fetchItems()
        items.removeAll { $0.id == id }
        try await localStorage.save(items, forKey: watchlistKey)
    }
    
    func updateAlert(id: String, price: Double?) async throws {
        var items = try await fetchItems()
        
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            throw DomainError.assetNotFound
        }
        
        items[index].alertPrice = price
        try await localStorage.save(items, forKey: watchlistKey)
    }
    
    func isInWatchlist(id: String) async throws -> Bool {
        let items = try await fetchItems()
        return items.contains { $0.id == id }
    }
}
