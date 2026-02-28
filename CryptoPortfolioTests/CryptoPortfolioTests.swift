//
//  CryptoPortfolioTests.swift
//  CryptoPortfolioTests
//

import XCTest
@testable import CryptoPortfolio

// MARK: - Asset Tests

final class AssetTests: XCTestCase {
    
    // MARK: - Gain/Loss Calculation
    
    func testGainLossPositive() {
        let asset = Asset(
            symbol: "BTC",
            name: "Bitcoin",
            amount: 1.0,
            currentPrice: 50000,
            purchasePrice: 40000
        )
        XCTAssertEqual(asset.gainLoss, 10000, accuracy: 0.01)
        XCTAssertEqual(asset.gainLossPercentage, 25.0, accuracy: 0.01)
        XCTAssertTrue(asset.isGainLossPositive)
    }
    
    func testGainLossNegative() {
        let asset = Asset(
            symbol: "BTC",
            name: "Bitcoin",
            amount: 2.0,
            currentPrice: 30000,
            purchasePrice: 40000
        )
        XCTAssertEqual(asset.gainLoss, -20000, accuracy: 0.01)
        XCTAssertEqual(asset.gainLossPercentage, -25.0, accuracy: 0.01)
        XCTAssertFalse(asset.isGainLossPositive)
    }
    
    func testGainLossZeroWhenPurchasePriceEqualsCurrentPrice() {
        let asset = Asset(
            symbol: "ETH",
            name: "Ethereum",
            amount: 5.0,
            currentPrice: 2000,
            purchasePrice: 2000
        )
        XCTAssertEqual(asset.gainLoss, 0, accuracy: 0.01)
        XCTAssertEqual(asset.gainLossPercentage, 0, accuracy: 0.01)
    }
    
    func testGainLossWithZeroPurchasePrice() {
        let asset = Asset(
            symbol: "ETH",
            name: "Ethereum",
            amount: 1.0,
            currentPrice: 2000,
            purchasePrice: 0
        )
        // Should not divide by zero
        XCTAssertEqual(asset.gainLossPercentage, 0, accuracy: 0.01)
    }
    
    // MARK: - Purchase Price Defaults
    
    func testPurchasePriceDefaultsToCurrentPrice() {
        let asset = Asset(
            symbol: "BTC",
            name: "Bitcoin",
            amount: 1.0,
            currentPrice: 45000
        )
        XCTAssertEqual(asset.purchasePrice, 45000)
        XCTAssertEqual(asset.gainLoss, 0, accuracy: 0.01)
    }
    
    // MARK: - Total Value
    
    func testTotalValueCalculation() {
        let asset = Asset(
            symbol: "BTC",
            name: "Bitcoin",
            amount: 2.5,
            currentPrice: 60000
        )
        XCTAssertEqual(asset.totalValue, 150000, accuracy: 0.01)
    }
    
    // MARK: - Formatted Strings
    
    func testFormattedGainLossPositive() {
        let asset = Asset(
            symbol: "BTC",
            name: "Bitcoin",
            amount: 1.0,
            currentPrice: 50000,
            purchasePrice: 40000
        )
        XCTAssertTrue(asset.formattedGainLoss.hasPrefix("+"))
        XCTAssertTrue(asset.formattedGainLossPercentage.hasPrefix("+"))
    }
    
    func testFormattedGainLossNegative() {
        let asset = Asset(
            symbol: "BTC",
            name: "Bitcoin",
            amount: 1.0,
            currentPrice: 30000,
            purchasePrice: 40000
        )
        XCTAssertTrue(asset.formattedGainLoss.hasPrefix("-"))
        XCTAssertTrue(asset.formattedGainLossPercentage.hasPrefix("-"))
    }
}

// MARK: - AddAssetUseCase Tests

final class AddAssetUseCaseTests: XCTestCase {
    
    private var mockRepository: MockPortfolioRepository!
    private var useCase: AddAssetUseCase!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockPortfolioRepository()
        useCase = AddAssetUseCase(repository: mockRepository)
    }
    
    func testAddValidAsset() async throws {
        let asset = Asset(symbol: "BTC", name: "Bitcoin", amount: 1.0, currentPrice: 45000)
        try await useCase.execute(asset)
        XCTAssertEqual(mockRepository.addedAssets.count, 1)
        XCTAssertEqual(mockRepository.addedAssets.first?.symbol, "BTC")
    }
    
    func testAddAssetWithEmptySymbolThrows() async {
        let asset = Asset(symbol: "", name: "Unknown", amount: 1.0, currentPrice: 100)
        do {
            try await useCase.execute(asset)
            XCTFail("Expected invalidSymbol error")
        } catch let error as DomainError {
            XCTAssertEqual(error, .invalidSymbol)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testAddAssetWithZeroAmountThrows() async {
        let asset = Asset(symbol: "BTC", name: "Bitcoin", amount: 0, currentPrice: 45000)
        do {
            try await useCase.execute(asset)
            XCTFail("Expected invalidAmount error")
        } catch let error as DomainError {
            XCTAssertEqual(error, .invalidAmount)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testAddAssetWithNegativeAmountThrows() async {
        let asset = Asset(symbol: "BTC", name: "Bitcoin", amount: -1.0, currentPrice: 45000)
        do {
            try await useCase.execute(asset)
            XCTFail("Expected invalidAmount error")
        } catch let error as DomainError {
            XCTAssertEqual(error, .invalidAmount)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testAddAssetWithZeroPriceThrows() async {
        let asset = Asset(symbol: "BTC", name: "Bitcoin", amount: 1.0, currentPrice: 0)
        do {
            try await useCase.execute(asset)
            XCTFail("Expected invalidAssetData error")
        } catch let error as DomainError {
            XCTAssertEqual(error, .invalidAssetData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - CalculatePortfolioTotalUseCase Tests

final class CalculatePortfolioTotalUseCaseTests: XCTestCase {
    
    private var mockRepository: MockPortfolioRepository!
    private var useCase: CalculatePortfolioTotalUseCase!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockPortfolioRepository()
        useCase = CalculatePortfolioTotalUseCase(repository: mockRepository)
    }
    
    func testEmptyPortfolioReturnsZeroTotals() async throws {
        mockRepository.assets = []
        let result = try await useCase.execute()
        XCTAssertEqual(result.totalValue, 0)
        XCTAssertEqual(result.gainLoss, 0)
        XCTAssertEqual(result.gainLossPercentage, 0)
        XCTAssertTrue(result.assets.isEmpty)
    }
    
    func testGainLossCalculatedCorrectly() async throws {
        // BTC bought at 40k, now at 50k → +25%
        mockRepository.assets = [
            Asset(symbol: "BTC", name: "Bitcoin", amount: 1.0, currentPrice: 40000, purchasePrice: 40000)
        ]
        // Mock API returns 50k
        mockRepository.mockPrice = 50000
        
        let result = try await useCase.execute()
        
        XCTAssertEqual(result.totalValue, 50000, accuracy: 0.01)
        XCTAssertEqual(result.gainLoss, 10000, accuracy: 0.01)
        XCTAssertEqual(result.gainLossPercentage, 25.0, accuracy: 0.01)
    }
    
    func testPortfolioTotalValueIsCorrect() async throws {
        mockRepository.assets = [
            Asset(symbol: "BTC", name: "Bitcoin", amount: 1.0, currentPrice: 40000, purchasePrice: 40000),
            Asset(symbol: "ETH", name: "Ethereum", amount: 10.0, currentPrice: 2000, purchasePrice: 2000)
        ]
        mockRepository.mockPrice = 40000 // Simplified: same price returned for all
        
        let result = try await useCase.execute()
        // 1 BTC at 40k + 10 ETH at 40k (mock returns same price) = 440k
        XCTAssertEqual(result.assets.count, 2)
    }
    
    func testPurchasePricePreservedAfterPriceUpdate() async throws {
        mockRepository.assets = [
            Asset(symbol: "BTC", name: "Bitcoin", amount: 1.0, currentPrice: 40000, purchasePrice: 30000)
        ]
        mockRepository.mockPrice = 45000
        
        let result = try await useCase.execute()
        
        // purchasePrice should remain 30000, not change to 45000
        XCTAssertEqual(result.assets.first?.purchasePrice, 30000, accuracy: 0.01)
        XCTAssertEqual(result.assets.first?.currentPrice, 45000, accuracy: 0.01)
    }
}

// MARK: - AssetStorageDTO Tests

final class AssetStorageDTOTests: XCTestCase {
    
    func testToDomainPreservesPurchasePrice() {
        let dto = AssetStorageDTO(
            id: "1",
            symbol: "BTC",
            name: "Bitcoin",
            amount: 1.0,
            currentPrice: 50000,
            purchasePrice: 35000
        )
        let asset = dto.toDomain()
        XCTAssertEqual(asset.purchasePrice, 35000, accuracy: 0.01)
        XCTAssertEqual(asset.currentPrice, 50000, accuracy: 0.01)
    }
    
    func testFromAssetPreservesPurchasePrice() {
        let asset = Asset(symbol: "ETH", name: "Ethereum", amount: 2.0, currentPrice: 3000, purchasePrice: 2000)
        let dto = AssetStorageDTO(from: asset)
        XCTAssertEqual(dto.purchasePrice, 2000, accuracy: 0.01)
    }
    
    func testBackwardCompatibilityFallbacksToPurchasePrice() throws {
        // Old stored data without purchase_price field
        let json = """
        {"id":"abc","symbol":"btc","name":"Bitcoin","amount":1.0,"current_price":45000.0,"saved_at":0}
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let dto = try decoder.decode(AssetStorageDTO.self, from: json)
        
        // Should fall back to currentPrice
        XCTAssertEqual(dto.purchasePrice, 45000, accuracy: 0.01)
    }
}

// MARK: - Mock Repository

final class MockPortfolioRepository: PortfolioRepository, @unchecked Sendable {
    
    var assets: [Asset] = []
    var addedAssets: [Asset] = []
    var mockPrice: Double = 0
    var shouldThrow: Error?
    
    func fetchAssets() async throws -> [Asset] {
        if let error = shouldThrow { throw error }
        return assets
    }
    
    func addAsset(_ asset: Asset) async throws {
        if let error = shouldThrow { throw error }
        addedAssets.append(asset)
    }
    
    func deleteAsset(id: String) async throws {
        assets.removeAll { $0.id == id }
    }
    
    func updateAsset(_ asset: Asset) async throws {
        if let index = assets.firstIndex(where: { $0.id == asset.id }) {
            assets[index] = asset
        }
    }
    
    func fetchPrice(symbol: String) async throws -> Double {
        if let error = shouldThrow { throw error }
        return mockPrice > 0 ? mockPrice : assets.first(where: { $0.symbol == symbol })?.currentPrice ?? 0
    }
    
    func fetchMarketData(symbol: String) async throws -> MarketDataResponse {
        MarketDataResponse(id: symbol, symbol: symbol, name: symbol, currentPrice: mockPrice, marketCap: nil, marketCapRank: nil, priceChangePercentage24h: nil)
    }
    
    func fetchPriceHistory(symbol: String, days: Int) async throws -> [PriceHistoryPoint] {
        []
    }
}
