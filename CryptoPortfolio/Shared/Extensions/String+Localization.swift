//
//  String+Localization.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - String Localization Extension

extension String {
    
    /// Returns the localized version of the string using the current app language
    var localized: String {
        let languageCode = LanguageManager.shared.currentLanguage.code
        
        guard let bundlePath = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: bundlePath) else {
            // Fallback to main bundle if language-specific bundle not found
            return NSLocalizedString(self, comment: "")
        }
        
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
    
    /// Returns the localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
    
    /// Returns all available language codes in the app
    static var availableLanguages: [String] {
        Bundle.main.localizations.filter { $0 != "Base" }
    }
}

// MARK: - Localization Keys

/// Centralized localization keys for type-safe access
enum LocalizedKey {

    // MARK: - Tab Bar

    enum Tab {

        static let portfolio = "Tab.Portfolio"
        static let market = "Tab.Market"
        static let analytics = "Tab.Analytics"
        static let watchlist = "Tab.Watchlist"
        static let settings = "Tab.Settings"

    }

    // MARK: - Portfolio Screen

    enum Portfolio {

        static let title = "Portfolio.Title"
        static let emptyTitle = "Portfolio.Empty.Title"
        static let emptyMessage = "Portfolio.Empty.Message"
        static let addAsset = "Portfolio.AddAsset"
        static let totalValue = "Portfolio.TotalValue"
        static let loading = "Portfolio.Loading"
        static let errorTitle = "Portfolio.Error.Title"
        static let tryAgain = "Portfolio.TryAgain"
        static let deleteTitle = "Portfolio.Delete.Title"
        static let deleteMessage = "Portfolio.Delete.Message"

    }

    // MARK: - Market Screen

    enum Market {

        static let title = "Market.Title"
        static let searchPrompt = "Market.SearchPrompt"
        static let loading = "Market.Loading"
        static let emptyTitle = "Market.Empty.Title"

    }

    // MARK: - Analytics Screen

    enum Analytics {

        static let title = "Analytics.Title"
        static let performance = "Analytics.Performance"
        static let totalReturn = "Analytics.TotalReturn"
        static let change24h = "Analytics.24hChange"
        static let assetAllocation = "Analytics.AssetAllocation"
        static let noAssets = "Analytics.NoAssets"
        static let topPerformers = "Analytics.TopPerformers"
        static let noData = "Analytics.NoData"
        static let quickActions = "Analytics.QuickActions"
        static let export = "Analytics.Export"
        static let compare = "Analytics.Compare"
        static let alerts = "Analytics.Alerts"
        static let day = "Analytics.Timeframe.Day"
        static let week = "Analytics.Timeframe.Week"
        static let month = "Analytics.Timeframe.Month"
        static let year = "Analytics.Timeframe.Year"
        static let all = "Analytics.Timeframe.All"
        static let last24Hours = "Analytics.Timeframe.Last24Hours"
        static let last7Days = "Analytics.Timeframe.Last7Days"
        static let last30Days = "Analytics.Timeframe.Last30Days"
        static let lastYear = "Analytics.Timeframe.LastYear"
        static let allTime = "Analytics.Timeframe.AllTime"

    }

    // MARK: - Watchlist Screen

    enum Watchlist {

        static let title = "Watchlist.Title"
        static let emptyTitle = "Watchlist.Empty.Title"
        static let emptyMessage = "Watchlist.Empty.Message"
        static let browseMarket = "Watchlist.BrowseMarket"

    }

    // MARK: - Settings Screen

    enum Settings {

        static let title = "Settings.Title"
        static let appearance = "Settings.Appearance"
        static let theme = "Settings.Theme"
        static let language = "Settings.Language"
        static let currency = "Settings.Currency"
        static let notifications = "Settings.Notifications"
        static let enableNotifications = "Settings.EnableNotifications"
        static let about = "Settings.About"
        static let version = "Settings.Version"
        static let resetDefaults = "Settings.ResetDefaults"
        static let themeLight = "Settings.Theme.Light"
        static let themeDark = "Settings.Theme.Dark"
        static let themeSystem = "Settings.Theme.System"
        static let languageEnglish = "Settings.Language.English"
        static let languageSpanish = "Settings.Language.Spanish"
        static let languageSystem = "Settings.Language.System"

    }

    // MARK: - Add Asset Screen

    enum AddAsset {

        static let title = "AddAsset.Title"
        static let cryptocurrency = "AddAsset.Cryptocurrency"
        static let symbolPlaceholder = "AddAsset.SymbolPlaceholder"
        static let fetchPrice = "AddAsset.FetchPrice"
        static let amount = "AddAsset.Amount"
        static let currentPrice = "AddAsset.CurrentPrice"
        static let totalValue = "AddAsset.TotalValue"
        static let addToPortfolio = "AddAsset.AddToPortfolio"

    }

    // MARK: - Asset Detail Screen

    enum AssetDetail {

        static let marketData = "AssetDetail.MarketData"
        static let change24h = "AssetDetail.24hChange"
        static let marketCapRank = "AssetDetail.MarketCapRank"
        static let statistics = "AssetDetail.Statistics"
        static let high30d = "AssetDetail.High30d"
        static let low30d = "AssetDetail.Low30d"
        static let average30d = "AssetDetail.Average30d"
        static let marketCap = "AssetDetail.MarketCap"
        static let priceHistory = "AssetDetail.PriceHistory"
        static let noDataTitle = "AssetDetail.NoData.Title"
        static let noDataMessage = "AssetDetail.NoData.Message"
        static let removeFromPortfolio = "AssetDetail.RemoveFromPortfolio"
        static let deleteTitle = "AssetDetail.Delete.Title"
        static let deleteMessage = "AssetDetail.Delete.Message"

    }

    // MARK: - Common

    enum Common {

        static let ok = "Common.OK"
        static let cancel = "Common.Cancel"
        static let delete = "Common.Delete"
        static let error = "Common.Error"
        static let loading = "Common.Loading"
        static let retry = "Common.Retry"
        static let done = "Common.Done"
        static let save = "Common.Save"
        static let close = "Common.Close"

    }

}
