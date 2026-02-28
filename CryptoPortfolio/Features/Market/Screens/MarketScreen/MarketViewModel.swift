//
//  MarketViewModel.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation
import Combine

@MainActor
final class MarketViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var cryptocurrencies: [CryptoMarket] = []
    @Published var filteredCryptocurrencies: [CryptoMarket] = []
    @Published var searchText: String = "" {
        didSet {
            Task { await filterCryptocurrencies() }
        }
    }
    @Published var selectedCrypto: CryptoMarket?
    @Published var watchlistItems: [WatchlistItem] = []
    
    /// Unified view state
    @Published var state: MarketViewState = .idle
    
    /// Typed error
    @Published var error: DomainError?
    
    // Rate limiting
    @Published var retryCountdown: Int? = nil
    @Published var isRateLimited = false
    
    /// Loading states derived from state
    var isLoading: Bool { state.isLoading }
    @Published var isSearching = false
    var isSearchDisabled: Bool { isRateLimited || isLoading }
    var canRetry: Bool { !isRateLimited && !isLoading }
    var hasResults: Bool { !filteredCryptocurrencies.isEmpty }
    var isEmpty: Bool { cryptocurrencies.isEmpty && !isLoading }
    var displayedCryptocurrencies: [CryptoMarket] {
        searchText.isEmpty ? cryptocurrencies : filteredCryptocurrencies
    }
    
    // MARK: - Dependencies (UseCases)
    
    private let fetchMarketDataUseCase: any FetchMarketDataUseCaseProtocol
    private let searchCryptoUseCase: any SearchCryptoUseCaseProtocol
    private let fetchCryptoDetailUseCase: any FetchCryptoDetailUseCaseProtocol
    private let watchlistUseCases: WatchlistUseCases
    
    // MARK: - Task Management
    
    private var loadTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private var countdownTimer: Timer?
    
    // MARK: - Initialization
    
    init(
        fetchMarketDataUseCase: any FetchMarketDataUseCaseProtocol,
        searchCryptoUseCase: any SearchCryptoUseCaseProtocol,
        fetchCryptoDetailUseCase: any FetchCryptoDetailUseCaseProtocol,
        watchlistUseCases: WatchlistUseCases
    ) {
        self.fetchMarketDataUseCase = fetchMarketDataUseCase
        self.searchCryptoUseCase = searchCryptoUseCase
        self.fetchCryptoDetailUseCase = fetchCryptoDetailUseCase
        self.watchlistUseCases = watchlistUseCases
        self.filteredCryptocurrencies = []
        
        Task {
            await loadWatchlist()
        }
    }
    
    deinit {
        countdownTimer?.invalidate()
        loadTask?.cancel()
        searchTask?.cancel()
    }
    
    // MARK: - Watchlist Methods
    
    func loadWatchlist() async {
        do {
            watchlistItems = try await watchlistUseCases.getItems.execute()
        } catch {
            watchlistItems = []
        }
    }
    
    func isInWatchlist(id: String) -> Bool {
        watchlistItems.contains { $0.id == id }
    }
    
    func toggleWatchlist(crypto: CryptoMarket) async -> String {
        if isInWatchlist(id: crypto.id) {
            try? await watchlistUseCases.removeItem.execute(id: crypto.id)
            await loadWatchlist()
            return "Removed from watchlist"
        } else {
            let item = WatchlistItem(
                id: crypto.id,
                symbol: crypto.symbol,
                name: crypto.name,
                image: crypto.image
            )
            try? await watchlistUseCases.addItem.execute(item)
            await loadWatchlist()
            return "Added to watchlist"
        }
    }
    
    // MARK: - Public Methods
    
    /// Load top cryptocurrencies by market cap with cancellation
    func loadMarketData() async {
        guard !isRateLimited else { return }
        
        loadTask?.cancel()
        
        loadTask = Task { @MainActor in
            state = .loading
            error = nil
            
            do {
                print("🟡 [MarketViewModel] Fetching market data...")
                let cryptos = try await fetchMarketDataUseCase.execute(limit: 50)
                
                guard !Task.isCancelled else { return }
                
                print("🟢 [MarketViewModel] Loaded \(cryptos.count) cryptocurrencies")
                self.cryptocurrencies = cryptos
                self.filteredCryptocurrencies = cryptos
                self.state = .loaded(cryptos)
                self.clearRateLimit()
            } catch let domainError as DomainError {
                guard !Task.isCancelled else { return }
                
                if case .rateLimited(let retryAfter) = domainError {
                    startRateLimitCountdown(seconds: retryAfter ?? 60)
                }
                
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
    
    /// Search for cryptocurrencies with cancellation
    func searchMarket(query: String) async {
        guard !isRateLimited && !isLoading else { return }
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            filteredCryptocurrencies = cryptocurrencies
            return
        }
        
        searchTask?.cancel()
        
        searchTask = Task { @MainActor in
            isSearching = true
            error = nil
            
            do {
                print("🟡 [MarketViewModel] Searching for: '\(query)'")
                let results = try await searchCryptoUseCase.execute(query: query)
                
                guard !Task.isCancelled else { return }
                
                print("🟢 [MarketViewModel] Search returned \(results.count) results")
                
                let resultIds = Set(results.map { $0.id })
                filteredCryptocurrencies = cryptocurrencies.filter { resultIds.contains($0.id) }
                
                // If no matches, add search results
                if filteredCryptocurrencies.isEmpty {
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
            } catch let domainError as DomainError {
                guard !Task.isCancelled else { return }
                self.error = domainError
            } catch {
                guard !Task.isCancelled else { return }
                self.error = DomainError.unknown(error.localizedDescription)
            }
            
            isSearching = false
        }
        
        await searchTask?.value
    }
    
    /// Load detailed information for a specific cryptocurrency
    func loadCryptoDetail(id: String) async {
        guard !isRateLimited else { return }
        
        error = nil
        
        do {
            selectedCrypto = try await fetchCryptoDetailUseCase.execute(id: id)
        } catch let domainError as DomainError {
            self.error = domainError
        } catch {
            self.error = DomainError.unknown(error.localizedDescription)
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
    
    /// Clear error state
    func clearError() {
        error = nil
        if case .error = state {
            state = .idle
        }
    }
    
    /// Start countdown timer for rate limit
    func startRateLimitCountdown(seconds: Int) {
        isRateLimited = true
        retryCountdown = seconds
        
        countdownTimer?.invalidate()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if let current = self.retryCountdown {
                    if current > 0 {
                        self.retryCountdown = current - 1
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
        error = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        print("🟢 [MarketViewModel] Rate limit cleared, ready to retry")
    }
}
