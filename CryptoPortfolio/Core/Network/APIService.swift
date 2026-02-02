//
//  APIService.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import Foundation

protocol APIServiceProtocol: Sendable {
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable?,
        queryItems: [URLQueryItem]?
    ) async throws -> T
}

final class APIService: APIServiceProtocol, @unchecked Sendable {
    static let shared = APIService()
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        
        // 1. Build URL
        let url = try buildURL(endpoint: endpoint, queryItems: queryItems)
        
        // 2. Create Request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = APIConfig.requestTimeout
        
        // 3. Add Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // 4. Add Body (if any)
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        // 5. Make Request
        print("🟡 [APIService] Request: \(method.rawValue) \(url.absoluteString)")
        let (data, response) = try await session.data(for: request)
        
        // 6. Validate Response
        if let httpResponse = response as? HTTPURLResponse {
            print("🟡 [APIService] Response Status: \(httpResponse.statusCode)")
        }
        try validateResponse(response, data: data)
        
        // Print raw JSON for debugging (truncate if too large)
        if let jsonString = String(data: data, encoding: .utf8) {
            let preview = jsonString.count > 1000 ? String(jsonString.prefix(1000)) + "..." : jsonString
            print("📄 [APIService] Response JSON: \(preview)")
        }
        
        // 7. Decode Response
        do {
            let decoder = JSONDecoder()
            // Note: Models have their own CodingKeys, so we don't use keyDecodingStrategy
            let result = try decoder.decode(T.self, from: data)
            print("🟢 [APIService] Decoding successful for \(T.self)")
            return result
        } catch let decodingError as DecodingError {
            // Detailed decoding error logging
            print("🔴 [APIService] Decoding Error (\(T.self)): \(decodingError)")
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("   Type mismatch: expected \(type), at: \(context.codingPath)")
                print("   Debug description: \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("   Value not found: \(type), at: \(context.codingPath)")
            case .keyNotFound(let key, let context):
                print("   Key not found: '\(key.stringValue)', at: \(context.codingPath)")
            case .dataCorrupted(let context):
                print("   Data corrupted at: \(context.codingPath)")
            @unknown default:
                print("   Unknown decoding error")
            }
            throw NetworkError.decodingError(decodingError)
        } catch {
            print("🔴 [APIService] Unknown Error: \(error)")
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - Private Helpers
    
    private func buildURL(endpoint: String, queryItems: [URLQueryItem]?) throws -> URL {
        let urlString = APIConfig.baseURL + endpoint
        
        guard var components = URLComponents(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        return url
    }
    
    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 429:
            // Extract retry-after header if available
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
            let retrySeconds = retryAfter.flatMap { Int($0) }
            throw NetworkError.rateLimited(retryAfter: retrySeconds)
        case 400...499, 500...599:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}
