//
//  UserDefaultsLocalStorage.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation
import os.log

// MARK: - UserDefaults Implementation

/// UserDefaults-based implementation of LocalStorageProtocol
/// Includes robust error handling for data migration scenarios
final class UserDefaultsLocalStorage: LocalStorageProtocol, @unchecked Sendable {
    
    private let userDefaults: UserDefaults
    private let logger = Logger(subsystem: "CryptoPortfolio", category: "UserDefaultsLocalStorage")
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - LocalStorageProtocol
    
    func save<T: Codable>(_ value: T, forKey key: String) async throws {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(value)
            userDefaults.set(data, forKey: key)
        } catch {
            logger.error("Failed to encode data for key '\(key)': \(error.localizedDescription)")
            throw StorageError.encodingFailed(error)
        }
    }
    
    func fetch<T: Codable>(forKey key: String, as type: T.Type) async throws -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        // Try decoding with ISO8601 date strategy first
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.debug("ISO8601 decode failed for '\(key)', trying default strategy...")
        }
        
        // Fallback: try with default date strategy
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.debug("Default decode failed for '\(key)', trying secondsSince1970...")
        }
        
        // Fallback: try with secondsSince1970 date strategy
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.warning("All decode strategies failed for key '\(key)': \(error.localizedDescription)")
            throw StorageError.decodingFailed(error)
        }
    }
    
    /// Fetch with automatic corruption handling - returns nil instead of throwing on decode failure
    func fetchSafe<T: Codable>(forKey key: String, as type: T.Type, clearOnFailure: Bool = false) async -> T? {
        do {
            return try await fetch(forKey: key, as: type)
        } catch {
            logger.warning("Safe fetch failed for '\(key)': \(error.localizedDescription)")
            
            if clearOnFailure {
                logger.info("Clearing corrupted data for key '\(key)'")
                await delete(forKey: key)
            }
            
            return nil
        }
    }
    
    func delete(forKey key: String) async {
        userDefaults.removeObject(forKey: key)
    }
    
    func exists(forKey key: String) async -> Bool {
        userDefaults.object(forKey: key) != nil
    }
    
    func clearAll() async {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }
    
    /// Get raw data for a key (useful for debugging/migration)
    func getRawData(forKey key: String) -> Data? {
        userDefaults.data(forKey: key)
    }
    
    /// Check if data exists and is valid JSON
    func validateJSON(forKey key: String) -> Bool {
        guard let data = userDefaults.data(forKey: key) else {
            return false
        }
        
        do {
            _ = try JSONSerialization.jsonObject(with: data)
            return true
        } catch {
            return false
        }
    }
}
