//
//  DomainError.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Domain Error

/// Domain-level errors for the Portfolio feature
enum DomainError: LocalizedError, Equatable {
    // Network-related errors
    case network(NetworkError)
    
    // Storage-related errors
    case storage(StorageError)
    
    // Business logic errors
    case assetNotFound
    case invalidAssetData
    case invalidAmount
    case invalidSymbol
    case duplicateAsset
    
    // Rate limiting
    case rateLimited(retryAfter: Int?)
    
    // Unknown errors
    case unknown(String)
    
    // MARK: - Equatable
    
    static func == (lhs: DomainError, rhs: DomainError) -> Bool {
        switch (lhs, rhs) {
        case (.assetNotFound, .assetNotFound),
             (.invalidAssetData, .invalidAssetData),
             (.invalidAmount, .invalidAmount),
             (.invalidSymbol, .invalidSymbol),
             (.duplicateAsset, .duplicateAsset):
            return true
        case (.rateLimited(let lhsRetry), .rateLimited(let rhsRetry)):
            return lhsRetry == rhsRetry
        case (.unknown(let lhsMsg), .unknown(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.network(let lhsNet), .network(let rhsNet)):
            return lhsNet.localizedDescription == rhsNet.localizedDescription
        case (.storage(let lhsStor), .storage(let rhsStor)):
            return lhsStor.localizedDescription == rhsStor.localizedDescription
        default:
            return false
        }
    }
    
    // MARK: - LocalizedError
    
    var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.localizedDescription
        case .storage(let error):
            return error.localizedDescription
        case .assetNotFound:
            return "Asset not found in portfolio"
        case .invalidAssetData:
            return "Invalid asset data"
        case .invalidAmount:
            return "Amount must be greater than 0"
        case .invalidSymbol:
            return "Invalid cryptocurrency symbol"
        case .duplicateAsset:
            return "This asset already exists in your portfolio"
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                return "Rate limit exceeded. Please try again in \(seconds) seconds."
            }
            return "Rate limit exceeded. Please try again later."
        case .unknown(let message):
            return message
        }
    }
    
    // MARK: - Mapping
    
    /// Maps a NetworkError to DomainError
    static func from(networkError: NetworkError) -> DomainError {
        switch networkError {
        case .rateLimited(let retryAfter):
            return .rateLimited(retryAfter: retryAfter)
        case .notFound:
            return .assetNotFound
        default:
            return .network(networkError)
        }
    }
    
    /// Maps a StorageError to DomainError
    static func from(storageError: StorageError) -> DomainError {
        .storage(storageError)
    }
}
