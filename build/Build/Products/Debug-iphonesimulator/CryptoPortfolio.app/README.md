# Market Feature - CryptoPortfolio

Complete Market feature for browsing and searching cryptocurrencies.

## 📁 Architecture

```
Features/Market/
├── Models/
│   └── CryptoMarket.swift          ← Market data models
│
├── Services/
│   └── Market/
│       ├── MarketServiceProtocol.swift  ← Service protocol
│       └── MarketService.swift          ← Service implementation
│
└── Screens/
    └── MarketScreen/
        ├── MarketScreen.swift       ← View
        └── MarketViewModel.swift    ← ViewModel
```

## 🎯 Features

### MarketScreen
Browse top cryptocurrencies by market cap with comprehensive data:
- **Market Listing**: Display top 50 cryptos sorted by market cap
- **Search**: Real-time search by symbol or name
- **Pull to Refresh**: Refresh market data
- **Detailed Info**: Shows price, market cap, 24h change, rank
- **Add to Portfolio**: Quick action to add crypto to portfolio
- **Loading/Error/Empty States**: Proper state management

### Models

#### CryptoMarket
- `id`: String
- `symbol`: String
- `name`: String
- `currentPrice`: Double
- `marketCap`: Double?
- `marketCapRank`: Int?
- `priceChange24h`: Double?
- `image`: String?

**Computed Properties**:
- `priceChangePercentage24h`: Formatted price change
- `isPositiveChange`: Boolean indicating positive price movement
- `formattedPrice`: USD formatted price
- `formattedMarketCap`: Formatted market cap (T/B/M)
- `formattedPriceChange`: Formatted percentage change

#### CryptoSearchResult
Search result model from CoinGecko search API

#### SearchResponse
Wrapper for search API responses

### Services

#### MarketServiceProtocol
```swift
protocol MarketServiceProtocol: Sendable {
    func fetchMarketData(limit: Int) async throws -> [CryptoMarket]
    func searchCrypto(query: String) async throws -> [CryptoSearchResult]
    func fetchCryptoDetail(id: String) async throws -> CryptoMarket
}
```

#### MarketService
Implementation using APIService with CoinGecko API

**Key Features**:
- `nonisolated init(apiService:)` - Thread-safe initialization
- Async/await pattern
- Proper error handling
- Query parameter construction
- Snake_case to camelCase decoding

### ViewModel

#### MarketViewModel
- `@MainActor` decorated for main thread operations
- `import Combine` for reactive programming
- Published properties for state management

**Published Properties**:
- `cryptocurrencies`: Full list of loaded cryptos
- `filteredCryptocurrencies`: Filtered by search
- `searchText`: Current search query
- `isLoading`: Loading state for initial data
- `isSearching`: Loading state for searches
- `error`: Error message display
- `selectedCrypto`: Currently selected crypto

**Methods**:
- `loadMarketData()`: Load top 50 cryptos
- `searchMarket(query:)`: Search cryptocurrencies
- `loadCryptoDetail(id:)`: Load detailed crypto info
- `filterCryptocurrencies()`: Filter by search text
- `clearSearch()`: Reset search
- `clearError()`: Clear error message

## 🌐 API Integration

Uses CoinGecko API (free, no key required):
- Base URL: `https://api.coingecko.com/api/v3`
- `/coins/markets` - Top cryptos by market cap
- `/search` - Search cryptocurrencies
- `/coins/{id}` - Detailed crypto information

## 🎨 UI Features

### Screens
- **Loading State**: Spinner with message
- **Error State**: Error icon, message, and retry button
- **Empty State**: Message when no data
- **Market List**: Row-based list with:
  - Market rank badge
  - Crypto icon (async loaded from URL)
  - Name and symbol tag
  - Current price
  - 24h price change with arrow indicator
  - Market cap information
  - Add to portfolio button

### Search
- **Real-time Search**: Updates as user types
- **No Results State**: Helpful message when no matches
- **Clear Button**: Quick clear search

### Refresh
- **Pull to Refresh**: Standard SwiftUI refreshable modifier

## 🎯 Architecture Requirements Met

✅ **Directory Structure**
- Services: `Features/Market/Services/Market/`
- Screens: `Features/Market/Screens/MarketScreen/`
- Models: `Features/Market/Models/`

✅ **File Organization**
- Protocol and implementation in separate files
- View and ViewModel in separate files

✅ **Code Quality**
- `nonisolated init` in Service
- `@MainActor` in ViewModel
- `import Combine` in ViewModel
- Protocol-based dependency injection
- Async/await pattern
- Proper error handling
- Sendable conformance

✅ **Styling**
- Uses `AppTheme` from Theme/AppTheme.swift
- Consistent colors, typography, spacing
- Custom shadows and corner radius

## 🚀 Usage

### Add to AppView Navigation
```swift
MarketScreen()
```

### Inject Custom Service (Testing)
```swift
let mockService = MockMarketService()
MarketScreen(viewModel: MarketViewModel(service: mockService))
```

## 📝 Notes

- All API calls use the shared `APIService` instance
- Error handling converts `NetworkError` to user-friendly messages
- Search filters local results first, then shows API results
- Crypto icons are loaded asynchronously with fallback to symbol icon
- Market cap formatted as T/B/M for readability
- Price changes show directional arrows (up/down)

## 🔄 Dependencies

- **Core/Network/APIService.swift**: HTTP requests
- **Theme/AppTheme.swift**: Design system
- **Foundation + Combine**: Async/reactive programming
