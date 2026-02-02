//
//  NetworkError.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case serverError(statusCode: Int)
    case rateLimited(retryAfter: Int?)
    case unauthorized
    case forbidden
    case notFound
    case unknown(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received from server"
        case .decodingError(let error), .networkError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                return "Rate limit exceeded. Please try again in \(seconds) seconds."
            }
            return "Rate limit exceeded. Please try again later."
        case .unauthorized:
            return "Unauthorized - Please log in"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
