//
//  WatchlistViewModel.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation
import Combine

@MainActor
class WatchlistViewModel: ObservableObject {
    @Published var items: [WatchlistItem] = []
    
    private let service: WatchlistServiceProtocol
    
    init(service: WatchlistServiceProtocol = WatchlistService.shared) {
        self.service = service
    }
    
    func loadItems() {
        items = service.fetchItems()
    }
    
    func addItem(_ item: WatchlistItem) {
        service.addItem(item)
        loadItems()
    }
    
    func removeItem(id: String) {
        service.removeItem(id: id)
        loadItems()
    }
    
    func isInWatchlist(id: String) -> Bool {
        service.isInWatchlist(id: id)
    }
}
