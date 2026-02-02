//
//  MarketViewModel.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation
import Combine

@MainActor
class MarketViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var cryptocurrencies: [CryptoMarket] = []
    @Published var filteredCryptocurrencies: [CryptoMarket] = []
    @Published var searchText: String = "" {
        didSet {
            Task { await filterCryptocurrencies() }
        }
    }
    @Published var isLoading = false
    @Published var isSearching = false
    @Published var error: String?
    @Published var selectedCrypto: CryptoMarket?
    
    // Rate limiting countdown
    @Published var retryCountdown: Int? = nil
    @Published var isRateLimited = false
    
    // Watchlist
    @Published private(set) var watchlistItems: [WatchlistItem] = []
    
    // MARK: - Dependencies
    
    private let service: MarketServiceProtocol
    private let watchlistService: WatchlistServiceProtocol
    private var countdownTimer: Timer?
    
    // MARK: - Computed Properties
    
    var isSearchDisabled: Bool {
        isRateLimited || isLoading
    }
    
    var canRetry: Bool {
        !isRateLimited && !isLoading
    }
    
    // MARK: - Initialization
    
    init(
        service: MarketServiceProtocol = MarketService(),
        watchlistService: WatchlistServiceProtocol = WatchlistService.shared
    ) {
        self.service = service
        self.watchlistService = watchlistService
        self.filteredCryptocurrencies = []
        loadWatchlist()
    }
    
    deinit {
        countdownTimer?.invalidate()
    }
    
    // MARK: - Watchlist Methods
    
    func loadWatchlist() {
        watchlistItems = watchlistService.fetchItems()
    }
    
    func isInWatchlist(id: String) -> Bool {
        watchlistItems.contains { $0.id == id }
    }
    
    func toggleWatchlist(crypto: CryptoMarket) -> String {
        if isInWatchlist(id: crypto.id) {
            watchlistService.removeItem(id: crypto.id)
            loadWatchlist()
            return "Removed from watchlist"
        } else {
            let item = WatchlistItem(
                id: crypto.id,
                symbol: crypto.symbol,
                name: crypto.name,
                image: crypto.image
            )
            watchlistService.addItem(item)
            loadWatchlist()
            return "Added to watchlist"
        }
    }
    
    // MARK: - Public Methods
    
    /// Load top cryptocurrencies by market cap
    func loadMarketData() async {
        guard !isRateLimited else { return }
        
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            print("🟡 [MarketViewModel] Fetching market data...")
            cryptocurrencies = try await service.fetchMarketData(limit: 50)
            print("🟢 [MarketViewModel] Loaded \(cryptocurrencies.count) cryptocurrencies")
            filteredCryptocurrencies = cryptocurrencies
            clearRateLimit()
        } catch {
            print("🔴 [MarketViewModel] Error loading market data: \(error)")
            self.error = formatError(error)
        }
    }
    
    /// Search for cryptocurrencies
    func searchMarket(query: String) async {
        guard !isRateLimited && !isLoading else { return }
        
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            filteredCryptocurrencies = cryptocurrencies
            return
        }
        
        isSearching = true
        error = nil
        defer { isSearching = false }
        
        do {
            print("🟡 [MarketViewModel] Searching for: '\(query)'")
            let results = try await service.searchCrypto(query: query)
            print("🟢 [MarketViewModel] Search returned \(results.count) results")
            
            // Create a set of IDs for quick lookup
            let resultIds = Set(results.map { $0.id })
            
            // Filter cryptocurrencies that match search results
            filteredCryptocurrencies = cryptocurrencies.filter { resultIds.contains($0.id) }
            
            // If no matches in loaded cryptos, add search results
            if filteredCryptocurrencies.isEmpty {
                // Map search results to crypto market items with limited data
                filteredCryptocurrencies = results.compactMap { result in
                    CryptoMarket(
                        id: result.id,
                        symbol: result.symbol.lowercased(),
                        name: result.name,
                        currentPrice: 0,
                        marketCap: nil,
                        marketCapRank: result.marketCapRank,
                        priceChangePercentage24h: nil,
                        image: result.thumb
                    )
                }
            }
        } catch {
            print("🔴 [MarketViewModel] Error searching: \(error)")
            self.error = formatError(error)
            filteredCryptocurrencies = cryptocurrencies
        }
    }
    
    /// Load detailed information for a specific cryptocurrency
    func loadCryptoDetail(id: String) async {
        guard !isRateLimited else { return }
        
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            selectedCrypto = try await service.fetchCryptoDetail(id: id)
        } catch {
            self.error = formatError(error)
        }
    }
    
    /// Filter cryptocurrencies based on search text
    func filterCryptocurrencies() async {
        guard !isRateLimited else { return }
        
        if searchText.isEmpty {
            filteredCryptocurrencies = cryptocurrencies
        } else {
            await searchMarket(query: searchText)
        }
    }
    
    /// Clear search and filters
    func clearSearch() {
        guard !isRateLimited else { return }
        
        searchText = ""
        filteredCryptocurrencies = cryptocurrencies
        error = nil
    }
    
    /// Clear error message
    func clearError() {
        error = nil
    }
    
    /// Start countdown timer for rate limit
    func startRateLimitCountdown(seconds: Int) {
        isRateLimited = true
        retryCountdown = seconds
        
        // Invalidate existing timer
        countdownTimer?.invalidate()
        
        // Start new timer
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if let current = self.retryCountdown {
                    if current > 0 {
                        self.retryCountdown = current - 1
                        if current > 1 {
                            self.updateRateLimitError()
                        } else {
                            // Last second, clear everything
                            self.clearRateLimit()
                        }
                    } else {
                        self.clearRateLimit()
                    }
                }
            }
        }
    }
    
    /// Clear rate limit state
    func clearRateLimit() {
        isRateLimited = false
        retryCountdown = nil
        error = nil  // Clear the error message too
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        print("🟢 [MarketViewModel] Rate limit cleared, ready to retry")
    }
    
    // MARK: - Computed Properties
    
    var hasResults: Bool {
        !filteredCryptocurrencies.isEmpty
    }
    
    var isEmpty: Bool {
        cryptocurrencies.isEmpty && !isLoading
    }
    
    var displayedCryptocurrencies: [CryptoMarket] {
        searchText.isEmpty ? cryptocurrencies : filteredCryptocurrencies
    }
    
    // MARK: - Private Methods
    
    private func updateRateLimitError() {
        if let seconds = retryCountdown {
            error = "⏱️ Rate limit reached. Try again in \(seconds)s"
        }
    }
    
    private func formatError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidURL:
                return "Invalid URL. Please check your internet connection."
            case .invalidResponse:
                return "Invalid response from server."
            case .unauthorized:
                return "Unauthorized. Please try again."
            case .forbidden:
                return "Access denied."
            case .notFound:
                return "Resource not found."
            case .rateLimited(let retryAfter):
                let seconds = retryAfter ?? 60
                startRateLimitCountdown(seconds: seconds)
                return "⏱️ Rate limit reached. Try again in \(seconds)s"
            case .serverError(let statusCode):
                return "Server error: \(statusCode). Please try again later."
            case .encodingError:
                return "Failed to encode request."
            case .decodingError:
                return "Failed to decode response. Please try again."
            case .networkError:
                return "Network error. Please check your internet connection."
            case .noData:
                return "Failed to decode response. Please try again."
            case .unknown(_):
                return "Failed to decode response. Please try again."
            }
        }
        
        return error.localizedDescription
    }
}
