//
//  WatchlistUseCases.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - GetWatchlistItemsUseCase

protocol GetWatchlistItemsUseCaseProtocol: Sendable {
    func execute() async throws -> [WatchlistItem]
}

final class GetWatchlistItemsUseCase: GetWatchlistItemsUseCaseProtocol {
    
    private let repository: WatchlistRepository
    
    init(repository: WatchlistRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [WatchlistItem] {
        try await repository.fetchItems()
    }
}

// MARK: - AddWatchlistItemUseCase

protocol AddWatchlistItemUseCaseProtocol: Sendable {
    func execute(_ item: WatchlistItem) async throws
}

final class AddWatchlistItemUseCase: AddWatchlistItemUseCaseProtocol {
    
    private let repository: WatchlistRepository
    
    init(repository: WatchlistRepository) {
        self.repository = repository
    }
    
    func execute(_ item: WatchlistItem) async throws {
        try await repository.addItem(item)
    }
}

// MARK: - RemoveWatchlistItemUseCase

protocol RemoveWatchlistItemUseCaseProtocol: Sendable {
    func execute(id: String) async throws
}

final class RemoveWatchlistItemUseCase: RemoveWatchlistItemUseCaseProtocol {
    
    private let repository: WatchlistRepository
    
    init(repository: WatchlistRepository) {
        self.repository = repository
    }
    
    func execute(id: String) async throws {
        try await repository.removeItem(id: id)
    }
}

// MARK: - IsInWatchlistUseCase

protocol IsInWatchlistUseCaseProtocol: Sendable {
    func execute(id: String) async throws -> Bool
}

final class IsInWatchlistUseCase: IsInWatchlistUseCaseProtocol {
    
    private let repository: WatchlistRepository
    
    init(repository: WatchlistRepository) {
        self.repository = repository
    }
    
    func execute(id: String) async throws -> Bool {
        try await repository.isInWatchlist(id: id)
    }
}

// MARK: - WatchlistUseCases Bundle

/// Convenience struct to bundle related watchlist use cases
struct WatchlistUseCases: Sendable {
    let getItems: any GetWatchlistItemsUseCaseProtocol
    let addItem: any AddWatchlistItemUseCaseProtocol
    let removeItem: any RemoveWatchlistItemUseCaseProtocol
}
