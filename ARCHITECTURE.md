# CryptoPortfolio - Architecture Reference 🏗️

**Quick reference for this project**

---

## 📂 Folder Structure

```
CryptoPortfolio/
│
├── App/
│   ├── CryptoPortfolioApp.swift      (Entry point)
│   └── RootView.swift                 (Root navigation)
│
├── Core/
│   ├── Network/
│   │   ├── HTTPMethod.swift
│   │   ├── NetworkError.swift
│   │   ├── APIConfig.swift
│   │   └── APIService.swift
│   │
│   ├── Storage/
│   │   └── UserDefaultsService.swift (Later)
│   │
│   └── Utils/
│       └── Constants.swift
│
├── Features/
│   │
│   ├── Portfolio/
│   │   ├── Models/
│   │   │   └── Asset.swift
│   │   │
│   │   ├── Services/
│   │   │   └── Portfolio/
│   │   │       ├── PortfolioServiceProtocol.swift
│   │   │       └── PortfolioService.swift
│   │   │
│   │   └── Screens/
│   │       ├── PortfolioScreen/
│   │       │   ├── PortfolioScreen.swift
│   │       │   └── PortfolioViewModel.swift
│   │       │
│   │       ├── AssetDetailScreen/
│   │       │   ├── AssetDetailScreen.swift
│   │       │   └── AssetDetailViewModel.swift
│   │       │
│   │       └── AddAssetScreen/
│   │           ├── AddAssetScreen.swift
│   │           └── AddAssetViewModel.swift
│   │
│   ├── Market/
│   │   ├── Models/
│   │   │   └── CryptoPrice.swift
│   │   │
│   │   ├── Services/
│   │   │   └── Market/
│   │   │       ├── MarketServiceProtocol.swift
│   │   │       └── MarketService.swift
│   │   │
│   │   └── Screens/
│   │       └── MarketScreen/
│   │           ├── MarketScreen.swift
│   │           └── MarketViewModel.swift
│   │
│   └── Settings/
│       └── Screens/
│           └── SettingsScreen/
│               ├── SettingsScreen.swift
│               └── SettingsViewModel.swift
│
├── Shared/
│   ├── Components/
│   │   ├── Buttons/
│   │   └── Cards/
│   │
│   └── Extensions/
│       ├── Color+Extensions.swift
│       └── View+Extensions.swift
│
├── Navigation/
│   ├── Router.swift
│   └── Route.swift
│
└── Theme/
    └── AppTheme.swift
```

---

## 🔗 Data Flow

```
User Tap
    ↓
PortfolioScreen (View)
    ↓
PortfolioViewModel
    ↓ (calls via protocol)
PortfolioService
    ↓ (calls)
APIService
    ↓ HTTP
CoinGecko API
    ↓ JSON Response
APIService (decodes)
    ↓ Returns Model
PortfolioService
    ↓ Returns to
PortfolioViewModel (@Published updates)
    ↓ View observes
PortfolioScreen (re-renders)
```

---

## 🎯 Creating New Screen Checklist

### **1. Create Folders**
```
Features/[Feature]/Screens/[Screen]Screen/
├── [Screen]Screen.swift
└── [Screen]ViewModel.swift
```

### **2. ViewModel First**
```swift
@MainActor
class ScreenViewModel: ObservableObject {
    @Published var data: [Item] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let service: ServiceProtocol
    
    init(service: ServiceProtocol = Service()) {
        self.service = service
    }
    
    func loadData() async {
        // Implementation
    }
}
```

### **3. View Second**
```swift
struct ScreenView: View {
    @StateObject private var viewModel = ScreenViewModel()
    
    var body: some View {
        // UI
    }
}
```

---

## 🎨 Theme Usage

```swift
// Colors
AppTheme.Colors.primary
AppTheme.Colors.background
AppTheme.Colors.error

// Typography
.font(AppTheme.Typography.headline)
.font(AppTheme.Typography.body)

// Spacing
.padding(AppTheme.Spacing.md)
.padding(.horizontal, AppTheme.Spacing.lg)

// Corner Radius
.cornerRadius(AppTheme.CornerRadius.md)
```

---

## 🔌 API Reference

### **CoinGecko API**

**Base URL:** `https://api.coingecko.com/api/v3`

**Endpoints:**

1. **Get Prices:**
   ```
   GET /simple/price
   Params: ids, vs_currencies
   Example: /simple/price?ids=bitcoin,ethereum&vs_currencies=usd
   ```

2. **Market Data:**
   ```
   GET /coins/markets
   Params: vs_currency, order, per_page, page
   Example: /coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50
   ```

3. **Price History:**
   ```
   GET /coins/{id}/market_chart
   Params: vs_currency, days
   Example: /coins/bitcoin/market_chart?vs_currency=usd&days=7
   ```

**Rate Limit:** 50 calls/minute (free)

---

## ✅ Code Quality Rules

### **1. Always use protocols for services**
```swift
✅ protocol ServiceProtocol { }
❌ Direct class instantiation
```

### **2. Dependency injection in init**
```swift
✅ init(service: ServiceProtocol = Service())
❌ let service = Service()
```

### **3. @MainActor for ViewModels**
```swift
✅ @MainActor class ViewModel
❌ class ViewModel (can cause threading issues)
```

### **4. Weak self in Tasks**
```swift
✅ Task { [weak self] in }
❌ Task { self.load() }
```

### **5. Async/await (no completion handlers)**
```swift
✅ await service.fetch()
❌ service.fetch { completion }
```

---

## 🎯 This Project Specifics

### **Models:**
- Asset (portfolio item)
- CryptoPrice (market data)
- AppSettings (user preferences)

### **Services:**
- PortfolioService (local storage + sync)
- MarketService (CoinGecko API)
- SettingsService (UserDefaults)

### **Screens:**
- PortfolioScreen (main)
- AssetDetailScreen (drill-down)
- AddAssetScreen (modal)
- MarketScreen (browse)
- SettingsScreen (preferences)

---

## 📝 Git Workflow

```bash
# After each feature:
git add .
git commit -m "Add [feature name]"
git push

# Commit messages format:
"Add Portfolio screen"
"Fix asset deletion bug"
"Update theme colors"
```

---

**Reference this document while building!** 📖
