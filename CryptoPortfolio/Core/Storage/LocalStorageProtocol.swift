//
//  LocalStorageProtocol.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Local Storage Protocol

/// Protocol for local storage operations
protocol LocalStorageProtocol: Sendable {
    /// Save data to local storage
    func save<T: Codable>(_ value: T, forKey key: String) async throws
    
    /// Fetch data from local storage
    func fetch<T: Codable>(forKey key: String, as type: T.Type) async throws -> T?
    
    /// Delete data from local storage
    func delete(forKey key: String) async
    
    /// Check if data exists for key
    func exists(forKey key: String) async -> Bool
    
    /// Clear all data
    func clearAll() async
}

// MARK: - Storage Error

enum StorageError: LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case keyNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .keyNotFound:
            return "Data not found for key"
        case .invalidData:
            return "Invalid data format"
        }
    }
}
