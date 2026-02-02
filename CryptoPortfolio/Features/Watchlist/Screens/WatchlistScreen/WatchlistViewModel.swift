//
//  WatchlistViewModel.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation
import Combine

@MainActor
final class WatchlistViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var items: [WatchlistItem] = []
    
    /// Unified view state
    @Published var state: WatchlistViewState = .idle
    
    /// Typed error
    @Published var error: DomainError?
    
    /// Loading state
    var isLoading: Bool { state.isLoading }
    
    // MARK: - Dependencies (UseCases)
    
    private let getItemsUseCase: any GetWatchlistItemsUseCaseProtocol
    private let addItemUseCase: any AddWatchlistItemUseCaseProtocol
    private let removeItemUseCase: any RemoveWatchlistItemUseCaseProtocol
    
    // MARK: - Task Management
    
    private var loadTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(
        getItemsUseCase: any GetWatchlistItemsUseCaseProtocol,
        addItemUseCase: any AddWatchlistItemUseCaseProtocol,
        removeItemUseCase: any RemoveWatchlistItemUseCaseProtocol
    ) {
        self.getItemsUseCase = getItemsUseCase
        self.addItemUseCase = addItemUseCase
        self.removeItemUseCase = removeItemUseCase
    }
    
    // MARK: - Public Methods
    
    /// Load watchlist items with cancellation support
    func loadItems() async {
        loadTask?.cancel()
        
        loadTask = Task { @MainActor in
            state = .loading
            error = nil
            
            do {
                let watchlistItems = try await getItemsUseCase.execute()
                
                guard !Task.isCancelled else { return }
                
                self.items = watchlistItems
                self.state = watchlistItems.isEmpty ? .idle : .loaded(watchlistItems)
                self.error = nil
            } catch let domainError as DomainError {
                guard !Task.isCancelled else { return }
                self.state = .error(domainError)
                self.error = domainError
            } catch {
                guard !Task.isCancelled else { return }
                let wrappedError = DomainError.unknown(error.localizedDescription)
                self.state = .error(wrappedError)
                self.error = wrappedError
            }
        }
        
        await loadTask?.value
    }
    
    /// Add an item to the watchlist
    func addItem(_ item: WatchlistItem) async {
        do {
            try await addItemUseCase.execute(item)
            await loadItems()
        } catch let domainError as DomainError {
            self.error = domainError
        } catch {
            self.error = DomainError.unknown(error.localizedDescription)
        }
    }
    
    /// Remove an item from the watchlist
    func removeItem(id: String) async {
        do {
            try await removeItemUseCase.execute(id: id)
            await loadItems()
        } catch let domainError as DomainError {
            self.error = domainError
        } catch {
            self.error = DomainError.unknown(error.localizedDescription)
        }
    }
    
    /// Check if an item is in watchlist
    func isInWatchlist(id: String) -> Bool {
        items.contains { $0.id == id }
    }
    
    /// Clear error state
    func clearError() {
        error = nil
        if case .error = state {
            state = .idle
        }
    }
}
