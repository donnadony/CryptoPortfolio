//
//  WatchlistRepository.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Repository Protocol

protocol WatchlistRepository: Sendable {
    func fetchItems() async throws -> [WatchlistItem]
    func addItem(_ item: WatchlistItem) async throws
    func removeItem(id: String) async throws
    func updateAlert(id: String, price: Double?) async throws
    func isInWatchlist(id: String) async throws -> Bool
}

// MARK: - Implementation

final class WatchlistRepositoryImpl: WatchlistRepository, @unchecked Sendable {
    
    private let localDataSource: WatchlistLocalDataSourceProtocol
    
    init(localDataSource: WatchlistLocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }
    
    func fetchItems() async throws -> [WatchlistItem] {
        do {
            return try await localDataSource.fetchItems()
        } catch let error as StorageError {
            throw DomainError.from(storageError: error)
        }
    }
    
    func addItem(_ item: WatchlistItem) async throws {
        do {
            try await localDataSource.addItem(item)
        } catch let error as StorageError {
            throw DomainError.from(storageError: error)
        }
    }
    
    func removeItem(id: String) async throws {
        do {
            try await localDataSource.removeItem(id: id)
        } catch let error as StorageError {
            throw DomainError.from(storageError: error)
        }
    }
    
    func updateAlert(id: String, price: Double?) async throws {
        do {
            try await localDataSource.updateAlert(id: id, price: price)
        } catch let error as StorageError {
            throw DomainError.from(storageError: error)
        }
    }
    
    func isInWatchlist(id: String) async throws -> Bool {
        do {
            return try await localDataSource.isInWatchlist(id: id)
        } catch let error as StorageError {
            throw DomainError.from(storageError: error)
        }
    }
}
