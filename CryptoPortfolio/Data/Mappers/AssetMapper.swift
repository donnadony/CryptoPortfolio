//
//  AssetMapper.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import Foundation

// MARK: - Asset Mapper

/// Maps between DTOs and Domain models for Assets
enum AssetMapper {
    
    // MARK: - To Domain
    
    /// Maps storage DTO to domain Asset
    static func map(dto: AssetStorageDTO) -> Asset {
        dto.toDomain()
    }
    
    /// Maps storage DTOs to domain Assets
    static func map(dtos: [AssetStorageDTO]) -> [Asset] {
        dtos.map(map(dto:))
    }
    
    /// Maps API response DTO to domain Asset with amount
    static func map(
        dto: AssetPriceResponseDTO,
        amount: Double = 0
    ) -> Asset? {
        guard let price = dto.currentPrice else { return nil }
        
        return Asset(
            id: dto.id,
            symbol: dto.symbol,
            name: dto.name,
            amount: amount,
            currentPrice: price
        )
    }
    
    /// Maps market data DTO to domain Asset with amount
    static func map(
        dto: MarketDataResponseDTO,
        amount: Double = 0
    ) -> Asset? {
        guard let price = dto.currentPrice else { return nil }
        
        return Asset(
            id: dto.id,
            symbol: dto.symbol,
            name: dto.name,
            amount: amount,
            currentPrice: price
        )
    }
    
    // MARK: - To DTO
    
    /// Maps domain Asset to storage DTO
    static func map(asset: Asset) -> AssetStorageDTO {
        AssetStorageDTO(from: asset)
    }
    
    /// Maps domain Assets to storage DTOs
    static func map(assets: [Asset]) -> [AssetStorageDTO] {
        assets.map(map(asset:))
    }
}

// MARK: - Market Data Mapper

/// Maps between DTOs and Domain models for Market Data
enum MarketDataMapper {
    
    /// Maps API DTO to MarketDataResponse
    static func map(dto: MarketDataResponseDTO) -> MarketDataResponse {
        MarketDataResponse(
            id: dto.id,
            symbol: dto.symbol,
            name: dto.name,
            currentPrice: dto.currentPrice,
            marketCap: dto.marketCap,
            marketCapRank: dto.marketCapRank,
            priceChangePercentage24h: dto.priceChangePercentage24h
        )
    }
    
    /// Maps API DTOs to MarketDataResponses
    static func map(dtos: [MarketDataResponseDTO]) -> [MarketDataResponse] {
        dtos.map(map(dto:))
    }
}

// MARK: - Crypto Market Mapper

/// Maps between DTOs and Domain models for CryptoMarket
enum CryptoMarketMapper {
    
    /// Maps API DTO to domain CryptoMarket
    static func map(dto: CryptoMarketDTO) -> CryptoMarket {
        CryptoMarket(
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
    
    /// Maps API DTOs to domain CryptoMarkets
    static func map(dtos: [CryptoMarketDTO]) -> [CryptoMarket] {
        dtos.map(map(dto:))
    }
    
    /// Maps search result DTO to CryptoSearchResult
    static func map(dto: CryptoSearchResultDTO) -> CryptoSearchResult {
        CryptoSearchResult(
            id: dto.id,
            name: dto.name,
            symbol: dto.symbol,
            marketCapRank: dto.marketCapRank,
            thumb: dto.thumb
        )
    }
    
    /// Maps search result DTOs to CryptoSearchResults
    static func map(dtos: [CryptoSearchResultDTO]) -> [CryptoSearchResult] {
        dtos.map(map(dto:))
    }
}
