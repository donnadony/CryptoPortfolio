//
//  MockDataSources.swift
//  CryptoPortfolio
//
//  Offline mock data sources for UI Testing and screenshot generation.
//  Activated when the app is launched with "UI_TEST_MODE" in ProcessInfo.arguments.
//  Zero network calls — all data is returned instantly.
//

import Foundation

// MARK: - Mock Market Remote Data Source

final class MockMarketRemoteDataSource: MarketRemoteDataSourceProtocol, @unchecked Sendable {

    func fetchMarketData(limit: Int) async throws -> [CryptoMarketDTO] {
        return CryptoMarketDTO.mockList
    }

    func searchCrypto(query: String) async throws -> [CryptoSearchResultDTO] {
        return CryptoMarketDTO.mockList
            .filter {
                query.isEmpty ||
                $0.name.lowercased().contains(query.lowercased()) ||
                $0.symbol.lowercased().contains(query.lowercased())
            }
            .map {
                CryptoSearchResultDTO(
                    id: $0.id,
                    name: $0.name,
                    symbol: $0.symbol,
                    marketCapRank: $0.marketCapRank,
                    thumb: $0.image
                )
            }
    }

    func fetchCryptoDetail(id: String) async throws -> CryptoMarketDTO {
        return CryptoMarketDTO.mockList.first { $0.id == id } ?? CryptoMarketDTO.mockList[0]
    }
}

// MARK: - Mock Portfolio Remote Data Source

final class MockPortfolioRemoteDataSource: PortfolioRemoteDataSourceProtocol, @unchecked Sendable {

    private let prices: [String: Double] = [
        "BTC": 95000.0, "ETH": 3500.0, "SOL": 175.0,
        "BNB": 620.0, "XRP": 2.10, "ADA": 0.85
    ]

    func fetchPrice(symbol: String) async throws -> Double {
        return prices[symbol.uppercased()] ?? 100.0
    }

    func fetchMarketData(symbol: String) async throws -> MarketDataResponseDTO {
        let dto = CryptoMarketDTO.mockList.first { $0.symbol.uppercased() == symbol.uppercased() }
            ?? CryptoMarketDTO.mockList[0]
        return MarketDataResponseDTO(
            id: dto.id,
            symbol: dto.symbol,
            name: dto.name,
            currentPrice: dto.currentPrice,
            marketCap: dto.marketCap,
            marketCapRank: dto.marketCapRank,
            priceChangePercentage24h: dto.priceChangePercentage24h,
            image: dto.image
        )
    }

    func fetchPriceHistory(symbol: String, days: Int) async throws -> PriceHistoryResponseDTO {
        // Generate a sine-wave price history so charts render something interesting
        let base = prices[symbol.uppercased()] ?? 95000.0
        let now = Date().timeIntervalSince1970 * 1000
        let dayMs = 86_400_000.0
        let rawPrices = (0..<max(days, 7)).map { i -> [Double] in
            let t = Double(i) / Double(max(days - 1, 1))
            let price = base * (0.85 + 0.15 * sin(t * .pi * 2))
            let timestamp = now - Double(days - i) * dayMs
            return [timestamp, price]
        }
        return PriceHistoryResponseDTO(prices: rawPrices, marketCaps: nil, volumes: nil)
    }
}

// MARK: - Mock Portfolio Local Data Source

final class MockPortfolioLocalDataSource: PortfolioLocalDataSourceProtocol, @unchecked Sendable {

    private var assets: [AssetStorageDTO] = [
        AssetStorageDTO(id: "btc-mock", symbol: "BTC", name: "Bitcoin",
                        amount: 0.5, currentPrice: 95000.0, purchasePrice: 60000.0),
        AssetStorageDTO(id: "eth-mock", symbol: "ETH", name: "Ethereum",
                        amount: 3.0, currentPrice: 3500.0, purchasePrice: 2200.0),
        AssetStorageDTO(id: "sol-mock", symbol: "SOL", name: "Solana",
                        amount: 20.0, currentPrice: 175.0, purchasePrice: 90.0)
    ]

    func fetchAssets() async throws -> [AssetStorageDTO] { assets }

    func saveAssets(_ newAssets: [AssetStorageDTO]) async throws { assets = newAssets }

    func addAsset(_ asset: AssetStorageDTO) async throws { assets.append(asset) }

    func deleteAsset(id: String) async throws { assets.removeAll { $0.id == id } }

    func updateAsset(_ asset: AssetStorageDTO) async throws {
        if let i = assets.firstIndex(where: { $0.id == asset.id }) { assets[i] = asset }
    }

    func clearAssets() async { assets = [] }
}

// MARK: - Hardcoded Mock Market Data

extension CryptoMarketDTO {
    static let mockList: [CryptoMarketDTO] = [
        CryptoMarketDTO(id: "bitcoin",      symbol: "BTC",  name: "Bitcoin",
                        currentPrice: 95000.0,  marketCap: 1_870_000_000_000, marketCapRank: 1,
                        priceChangePercentage24h: 2.45,
                        image: "https://assets.coingecko.com/coins/images/1/thumb/bitcoin.png"),
        CryptoMarketDTO(id: "ethereum",     symbol: "ETH",  name: "Ethereum",
                        currentPrice: 3500.0,   marketCap: 420_000_000_000,   marketCapRank: 2,
                        priceChangePercentage24h: 1.82,
                        image: "https://assets.coingecko.com/coins/images/279/thumb/ethereum.png"),
        CryptoMarketDTO(id: "solana",       symbol: "SOL",  name: "Solana",
                        currentPrice: 175.0,    marketCap: 82_000_000_000,    marketCapRank: 3,
                        priceChangePercentage24h: -0.95,
                        image: "https://assets.coingecko.com/coins/images/4128/thumb/solana.png"),
        CryptoMarketDTO(id: "binancecoin",  symbol: "BNB",  name: "BNB",
                        currentPrice: 620.0,    marketCap: 90_000_000_000,    marketCapRank: 4,
                        priceChangePercentage24h: 0.60,
                        image: "https://assets.coingecko.com/coins/images/825/thumb/bnb-icon2_2x.png"),
        CryptoMarketDTO(id: "ripple",       symbol: "XRP",  name: "XRP",
                        currentPrice: 2.10,     marketCap: 120_000_000_000,   marketCapRank: 5,
                        priceChangePercentage24h: -1.25,
                        image: "https://assets.coingecko.com/coins/images/44/thumb/xrp-symbol-white-128.png"),
        CryptoMarketDTO(id: "cardano",      symbol: "ADA",  name: "Cardano",
                        currentPrice: 0.85,     marketCap: 30_000_000_000,    marketCapRank: 6,
                        priceChangePercentage24h: 3.10,
                        image: "https://assets.coingecko.com/coins/images/975/thumb/cardano.png"),
        CryptoMarketDTO(id: "dogecoin",     symbol: "DOGE", name: "Dogecoin",
                        currentPrice: 0.32,     marketCap: 47_000_000_000,    marketCapRank: 7,
                        priceChangePercentage24h: -2.80,
                        image: "https://assets.coingecko.com/coins/images/5/thumb/dogecoin.png"),
        CryptoMarketDTO(id: "polkadot",     symbol: "DOT",  name: "Polkadot",
                        currentPrice: 8.50,     marketCap: 12_000_000_000,    marketCapRank: 8,
                        priceChangePercentage24h: 1.40,
                        image: "https://assets.coingecko.com/coins/images/12171/thumb/polkadot.png")
    ]
}
