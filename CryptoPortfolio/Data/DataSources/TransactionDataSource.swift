//
//  TransactionDataSource.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 2/1/26.
//

import Foundation

/// Protocol for transaction/asset data source
protocol TransactionDataSource: Sendable {
    func getAssets() async throws -> [Asset]
}

/// Mock implementation for testing
final class MockTransactionDataSource: TransactionDataSource {
    func getAssets() async throws -> [Asset] {
        // Return empty array - assets come from other sources
        return []
    }
}
