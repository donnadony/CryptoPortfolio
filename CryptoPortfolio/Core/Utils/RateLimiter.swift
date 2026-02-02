//
//  RateLimiter.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation

/// Rate limiter to prevent exceeding API limits
actor RateLimiter {
    static let shared = RateLimiter()
    
    private var lastRequestTime: Date?
    private let minimumInterval: TimeInterval = 1.2 // Seconds between requests
    
    private init() {}
    
    /// Wait if needed to respect rate limits
    func waitIfNeeded() async {
        if let lastTime = lastRequestTime {
            let timeSinceLastRequest = Date().timeIntervalSince(lastTime)
            if timeSinceLastRequest < minimumInterval {
                let waitTime = minimumInterval - timeSinceLastRequest
                print("⏱️ [RateLimiter] Waiting \(String(format: "%.2f", waitTime))s...")
                try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
        }
        lastRequestTime = Date()
    }
    
    /// Reset the rate limiter (e.g., after a long pause)
    func reset() {
        lastRequestTime = nil
    }
}
