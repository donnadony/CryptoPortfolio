//
//  Container.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Dependency Container

/// Central dependency injection container that manages all app dependencies
final class Container: ObservableObject {
    
    // MARK: - Shared Instance
    
    /// Shared instance for app-wide access via @EnvironmentObject
    nonisolated(unsafe) static let shared = Container()
    
    // MARK: - Core Dependencies
    
    let apiService: APIServiceProtocol
    let localStorage: LocalStorageProtocol
    let rateLimiter: RateLimiter
    
    // MARK: - Data Sources
    
    let portfolioRemoteDataSource: PortfolioRemoteDataSourceProtocol
    let portfolioLocalDataSource: PortfolioLocalDataSourceProtocol
    let marketRemoteDataSource: MarketRemoteDataSourceProtocol
    let watchlistLocalDataSource: WatchlistLocalDataSourceProtocol
    let settingsLocalDataSource: SettingsLocalDataSourceProtocol
    
    // MARK: - Repositories
    
    let portfolioRepository: PortfolioRepository
    let marketRepository: MarketRepository
    let watchlistRepository: WatchlistRepository
    let settingsRepository: SettingsRepository
    
    // MARK: - Use Cases
    
    let getAssetsUseCase: any GetAssetsUseCaseProtocol
    let addAssetUseCase: any AddAssetUseCaseProtocol
    let updateAssetUseCase: any UpdateAssetUseCaseProtocol
    let deleteAssetUseCase: any DeleteAssetUseCaseProtocol
    let calculatePortfolioTotalUseCase: any CalculatePortfolioTotalUseCaseProtocol
    let fetchPriceUseCase: any FetchPriceUseCaseProtocol
    let portfolioFetchMarketDataUseCase: any PortfolioFetchMarketDataUseCaseProtocol
    let fetchMarketDataUseCase: any FetchMarketDataUseCaseProtocol
    let searchCryptoUseCase: any SearchCryptoUseCaseProtocol
    let fetchCryptoDetailUseCase: any FetchCryptoDetailUseCaseProtocol
    let getWatchlistItemsUseCase: any GetWatchlistItemsUseCaseProtocol
    let addWatchlistItemUseCase: any AddWatchlistItemUseCaseProtocol
    let removeWatchlistItemUseCase: any RemoveWatchlistItemUseCaseProtocol
    let loadSettingsUseCase: any LoadSettingsUseCaseProtocol
    let saveSettingsUseCase: any SaveSettingsUseCaseProtocol
    
    // MARK: - Services (Legacy bridge for gradual migration)
    
    let portfolioService: PortfolioServiceProtocol
    let marketService: MarketServiceProtocol
    let watchlistService: WatchlistServiceProtocol
    let settingsService: SettingsServiceProtocol
    
    // MARK: - Initialization
    
    /// Returns true when running in UI Test / screenshot mode
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TEST_MODE")
    }

    private init() {
        // Core Dependencies
        self.apiService = APIService()
        self.localStorage = UserDefaultsLocalStorage()
        self.rateLimiter = RateLimiter()
        
        // Data Sources — use offline mocks in UI test mode so tests don't hang on network
        let isTesting = Container.isUITesting
        self.portfolioRemoteDataSource = isTesting
            ? MockPortfolioRemoteDataSource()
            : PortfolioRemoteDataSource(apiService: apiService)
        self.portfolioLocalDataSource = isTesting
            ? MockPortfolioLocalDataSource()
            : PortfolioLocalDataSource(localStorage: localStorage)
        self.marketRemoteDataSource = isTesting
            ? MockMarketRemoteDataSource()
            : MarketRemoteDataSource(apiService: apiService, rateLimiter: rateLimiter)
        self.watchlistLocalDataSource = WatchlistLocalDataSource(localStorage: localStorage)
        self.settingsLocalDataSource = SettingsLocalDataSource(localStorage: localStorage)
        
        // Repositories
        self.portfolioRepository = PortfolioRepositoryImpl(
            remoteDataSource: portfolioRemoteDataSource,
            localDataSource: portfolioLocalDataSource
        )
        self.marketRepository = MarketRepositoryImpl(remoteDataSource: marketRemoteDataSource)
        self.watchlistRepository = WatchlistRepositoryImpl(localDataSource: watchlistLocalDataSource)
        self.settingsRepository = SettingsRepositoryImpl(localDataSource: settingsLocalDataSource)
        
        // Use Cases
        self.getAssetsUseCase = GetAssetsUseCase(repository: portfolioRepository)
        self.addAssetUseCase = AddAssetUseCase(repository: portfolioRepository)
        self.updateAssetUseCase = UpdateAssetUseCase(repository: portfolioRepository)
        self.deleteAssetUseCase = DeleteAssetUseCase(repository: portfolioRepository)
        self.calculatePortfolioTotalUseCase = CalculatePortfolioTotalUseCase(repository: portfolioRepository)
        self.fetchPriceUseCase = FetchPriceUseCase(repository: portfolioRepository)
        self.portfolioFetchMarketDataUseCase = PortfolioFetchMarketDataUseCase(repository: portfolioRepository)
        self.fetchMarketDataUseCase = FetchMarketDataUseCase(repository: marketRepository)
        self.searchCryptoUseCase = SearchCryptoUseCase(repository: marketRepository)
        self.fetchCryptoDetailUseCase = FetchCryptoDetailUseCase(repository: marketRepository)
        self.getWatchlistItemsUseCase = GetWatchlistItemsUseCase(repository: watchlistRepository)
        self.addWatchlistItemUseCase = AddWatchlistItemUseCase(repository: watchlistRepository)
        self.removeWatchlistItemUseCase = RemoveWatchlistItemUseCase(repository: watchlistRepository)
        self.loadSettingsUseCase = LoadSettingsUseCase(repository: settingsRepository)
        self.saveSettingsUseCase = SaveSettingsUseCase(repository: settingsRepository)
        
        // Services
        self.portfolioService = PortfolioServiceImpl(repository: portfolioRepository)
        self.marketService = MarketServiceImpl(repository: marketRepository)
        self.watchlistService = WatchlistServiceImpl(repository: watchlistRepository)
        self.settingsService = SettingsServiceImpl(repository: settingsRepository)
    }
}

// MARK: - ViewModel Factory

extension Container {
    /// Creates a PortfolioViewModel with injected dependencies
    @MainActor
    func makePortfolioViewModel() -> PortfolioViewModel {
        PortfolioViewModel(
            getAssetsUseCase: getAssetsUseCase,
            calculatePortfolioTotalUseCase: calculatePortfolioTotalUseCase,
            deleteAssetUseCase: deleteAssetUseCase
        )
    }
    
    /// Creates an AddAssetViewModel with injected dependencies
    @MainActor
    func makeAddAssetViewModel() -> AddAssetViewModel {
        AddAssetViewModel(
            addAssetUseCase: addAssetUseCase,
            fetchPriceUseCase: fetchPriceUseCase
        )
    }
    
    /// Creates an AssetDetailViewModel with injected dependencies
    @MainActor
    func makeAssetDetailViewModel(asset: Asset) -> AssetDetailViewModel {
        AssetDetailViewModel(
            asset: asset,
            updateAssetUseCase: updateAssetUseCase,
            deleteAssetUseCase: deleteAssetUseCase,
            portfolioFetchMarketDataUseCase: portfolioFetchMarketDataUseCase,
            fetchPriceHistoryUseCase: FetchPriceHistoryUseCase(repository: portfolioRepository)
        )
    }
    
    /// Creates a MarketViewModel with injected dependencies
    @MainActor
    func makeMarketViewModel() -> MarketViewModel {
        MarketViewModel(
            fetchMarketDataUseCase: fetchMarketDataUseCase,
            searchCryptoUseCase: searchCryptoUseCase,
            fetchCryptoDetailUseCase: fetchCryptoDetailUseCase,
            watchlistUseCases: WatchlistUseCases(
                getItems: getWatchlistItemsUseCase,
                addItem: addWatchlistItemUseCase,
                removeItem: removeWatchlistItemUseCase
            )
        )
    }
    
    /// Creates a WatchlistViewModel with injected dependencies
    @MainActor
    func makeWatchlistViewModel() -> WatchlistViewModel {
        WatchlistViewModel(
            getItemsUseCase: getWatchlistItemsUseCase,
            addItemUseCase: addWatchlistItemUseCase,
            removeItemUseCase: removeWatchlistItemUseCase
        )
    }
    
    /// Creates a SettingsViewModel with injected dependencies
    @MainActor
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            loadSettingsUseCase: loadSettingsUseCase,
            saveSettingsUseCase: saveSettingsUseCase
        )
    }
    
    /// Creates an AnalyticsDashboardViewModel with injected dependencies
    @MainActor
    func makeAnalyticsDashboardViewModel() -> AnalyticsDashboardViewModel {
        AnalyticsDashboardViewModel(
            getAssetsUseCase: getAssetsUseCase,
            calculatePortfolioTotalUseCase: calculatePortfolioTotalUseCase
        )
    }
    
    /// Returns the shared LanguageManager instance
    @MainActor
    func makeLanguageManager() -> LanguageManager {
        LanguageManager.shared
    }
    
    /// Returns the shared ThemeManager instance
    @MainActor
    func makeThemeManager() -> ThemeManager {
        ThemeManager.shared
    }
    
    // MARK: - Generic Resolve
    
    /// Resolve any type from the container, returns nil if unregistered
    func resolve<T>(_ type: T.Type) -> T? {
        if type is TransactionDataSource.Type {
            return MockTransactionDataSource() as? T
        }
        return nil
    }
}

// MARK: - Environment Key

private struct ContainerKey: EnvironmentKey {
    static let defaultValue = Container.shared
}

extension EnvironmentValues {
    var container: Container {
        get { self[ContainerKey.self] }
        set { self[ContainerKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    func withContainer() -> some View {
        self.environmentObject(Container.shared)
    }
}
