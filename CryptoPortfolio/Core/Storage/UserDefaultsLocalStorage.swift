//
//  UserDefaultsLocalStorage.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - UserDefaults Implementation

/// UserDefaults-based implementation of LocalStorageProtocol
final class UserDefaultsLocalStorage: LocalStorageProtocol, @unchecked Sendable {
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - LocalStorageProtocol
    
    func save<T: Codable>(_ value: T, forKey key: String) async throws {
        do {
            let data = try JSONEncoder().encode(value)
            userDefaults.set(data, forKey: key)
        } catch {
            throw StorageError.encodingFailed(error)
        }
    }
    
    func fetch<T: Codable>(forKey key: String, as type: T.Type) async throws -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw StorageError.decodingFailed(error)
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
}
