//
//  WatchlistServiceImpl.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

/// Service implementation that uses Repository pattern
final class WatchlistServiceImpl: WatchlistServiceProtocol, @unchecked Sendable {
    
    private let repository: WatchlistRepository
    
    init(repository: WatchlistRepository) {
        self.repository = repository
    }
    
    func fetchItems() -> [WatchlistItem] {
        // For synchronous API compatibility - returns empty on error
        // In production, consider making the protocol async
        do {
            return try runAsyncAndBlock {
                try await self.repository.fetchItems()
            } ?? []
        } catch {
            return []
        }
    }
    
    func addItem(_ item: WatchlistItem) {
        Task {
            try? await repository.addItem(item)
        }
    }
    
    func removeItem(id: String) {
        Task {
            try? await repository.removeItem(id: id)
        }
    }
    
    func updateAlert(id: String, price: Double?) {
        Task {
            try? await repository.updateAlert(id: id, price: price)
        }
    }
    
    func isInWatchlist(id: String) -> Bool {
        do {
            return try runAsyncAndBlock {
                try await self.repository.isInWatchlist(id: id)
            } ?? false
        } catch {
            return false
        }
    }
}

// Helper function for synchronous bridge during migration
private func runAsyncAndBlock<T>(_ operation: @Sendable @escaping () async throws -> T) throws -> T? {
    let semaphore = DispatchSemaphore(value: 0)
    var result: T?
    var thrownError: Error?
    
    Task {
        do {
            result = try await operation()
        } catch {
            thrownError = error
        }
        semaphore.signal()
    }
    
    semaphore.wait()
    
    if let error = thrownError {
        throw error
    }
    return result
}
