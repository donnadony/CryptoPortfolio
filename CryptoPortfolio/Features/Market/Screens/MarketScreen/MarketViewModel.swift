//
//  MarketViewModel.swift
//  CryptoPortfolio
//
//  Created on 31/01/2026.
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
    
    // MARK: - Dependencies
    
    private let service: MarketServiceProtocol
    
    // MARK: - Initialization
    
    init(service: MarketServiceProtocol = MarketService()) {
        self.service = service
        self.filteredCryptocurrencies = []
    }
    
    // MARK: - Public Methods
    
    /// Load top cryptocurrencies by market cap
    func loadMarketData() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            cryptocurrencies = try await service.fetchMarketData(limit: 50)
            filteredCryptocurrencies = cryptocurrencies
        } catch {
            self.error = formatError(error)
        }
    }
    
    /// Search for cryptocurrencies
    func searchMarket(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            filteredCryptocurrencies = cryptocurrencies
            return
        }
        
        isSearching = true
        error = nil
        defer { isSearching = false }
        
        do {
            let results = try await service.searchCrypto(query: query)
            
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
                        marketCapRank: result.marketData?.marketCapRank,
                        priceChange24h: nil,
                        image: result.thumb
                    )
                }
            }
        } catch {
            self.error = formatError(error)
            filteredCryptocurrencies = cryptocurrencies
        }
    }
    
    /// Load detailed information for a specific cryptocurrency
    func loadCryptoDetail(id: String) async {
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
        if searchText.isEmpty {
            filteredCryptocurrencies = cryptocurrencies
        } else {
            await searchMarket(query: searchText)
        }
    }
    
    /// Clear search and filters
    func clearSearch() {
        searchText = ""
        filteredCryptocurrencies = cryptocurrencies
        error = nil
    }
    
    /// Clear error message
    func clearError() {
        error = nil
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
            case .serverError(let statusCode):
                return "Server error: \(statusCode). Please try again later."
            case .encodingError:
                return "Failed to encode request."
            case .decodingError:
                return "Failed to decode response. Please try again."
            case .networkError:
                return "Network error. Please check your internet connection."
            }
        }
        
        return error.localizedDescription
    }
}
