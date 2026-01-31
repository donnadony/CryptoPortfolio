# CryptoPortfolio - Project Plan 📱

**iOS Crypto Portfolio Tracking App**

Created: January 31, 2026  
Start Date: February 1, 2026  
Target: 1 week (MVP)

---

## 🎯 Project Overview

**CryptoPortfolio** - Track your cryptocurrency investments with beautiful UI and real-time prices.

### **Core Features (MVP):**
1. ✅ Portfolio view (list of assets)
2. ✅ Add/Edit/Delete assets
3. ✅ Real-time price updates
4. ✅ Total portfolio value
5. ✅ Asset details view
6. ✅ Charts (price history)
7. ✅ Settings (units, theme)

### **Tech Stack:**
- SwiftUI
- MVVM Architecture
- Combine Framework
- Async/await
- CoinGecko API (free)

---

## 📂 Project Architecture

### **Using:** CORRECT Architecture Style

```
CryptoPortfolio/
├── App/
├── Core/
│   ├── Network/
│   ├── Storage/
│   └── Utils/
├── Features/
│   ├── Portfolio/
│   │   ├── Models/
│   │   ├── Services/Portfolio/
│   │   └── Screens/
│   │       ├── PortfolioScreen/
│   │       ├── AssetDetailScreen/
│   │       └── AddAssetScreen/
│   ├── Market/
│   └── Settings/
├── Shared/
├── Navigation/
└── Theme/
```

---

## 📋 Task Breakdown

### **Phase 1: Project Setup** (2-3 hours)
**Status:** 🟡 Ready to start

#### **Task 1.1: Create Xcode Project** (30 min)
- [ ] Open Xcode
- [ ] Create new App project
- [ ] Name: CryptoPortfolio
- [ ] SwiftUI + Swift
- [ ] Include tests

**Assigned to:** You (manual in Xcode)

---

#### **Task 1.2: Create Folder Structure** (15 min)
- [ ] Create all folders in Xcode:
  - App/
  - Core/Network/
  - Core/Storage/
  - Core/Utils/
  - Features/
  - Shared/Components/
  - Shared/Extensions/
  - Navigation/
  - Theme/

**Assigned to:** You (in Xcode)

---

#### **Task 1.3: Create Base Files** (1 hour)
- [ ] Core/Network/HTTPMethod.swift
- [ ] Core/Network/NetworkError.swift
- [ ] Core/Network/APIConfig.swift
- [ ] Core/Network/APIService.swift
- [ ] Core/Utils/Constants.swift
- [ ] Theme/AppTheme.swift
- [ ] Navigation/Route.swift
- [ ] Navigation/Router.swift
- [ ] Shared/Extensions/Color+Extensions.swift
- [ ] Shared/Extensions/View+Extensions.swift

**Assigned to:** Can delegate to assistant (I'll create the code)

---

#### **Task 1.4: Git Setup** (15 min)
- [ ] Initialize git
- [ ] Create .gitignore
- [ ] First commit
- [ ] Create GitHub repo
- [ ] Push to GitHub

**Assigned to:** Can delegate to assistant

---

### **Phase 2: Portfolio Feature** (4-5 hours)
**Status:** ⏳ Waiting for Phase 1

#### **Task 2.1: Models** (30 min)
- [ ] Features/Portfolio/Models/Asset.swift
- [ ] Features/Portfolio/Models/AssetAPIResponse.swift

**Assigned to:** Can delegate to assistant

---

#### **Task 2.2: Service** (1 hour)
- [ ] Features/Portfolio/Services/Portfolio/PortfolioServiceProtocol.swift
- [ ] Features/Portfolio/Services/Portfolio/PortfolioService.swift
- [ ] Implement:
  - fetchAssets()
  - addAsset()
  - deleteAsset()
  - updateAsset()

**Assigned to:** Can delegate to assistant

---

#### **Task 2.3: Portfolio Screen** (2 hours)
- [ ] Features/Portfolio/Screens/PortfolioScreen/PortfolioViewModel.swift
- [ ] Features/Portfolio/Screens/PortfolioScreen/PortfolioScreen.swift
- [ ] Features:
  - List assets
  - Show total value
  - Pull to refresh
  - Loading states
  - Error handling
  - Empty state

**Assigned to:** Split:
- ViewModel logic → Assistant
- UI design → You (customize appearance)

---

#### **Task 2.4: Add Asset Screen** (1.5 hours)
- [ ] Features/Portfolio/Screens/AddAssetScreen/AddAssetViewModel.swift
- [ ] Features/Portfolio/Screens/AddAssetScreen/AddAssetScreen.swift
- [ ] Features:
  - Symbol input
  - Amount input
  - Validation
  - Save action

**Assigned to:** Can delegate to assistant

---

#### **Task 2.5: Asset Detail Screen** (1 hour)
- [ ] Features/Portfolio/Screens/AssetDetailScreen/AssetDetailViewModel.swift
- [ ] Features/Portfolio/Screens/AssetDetailScreen/AssetDetailScreen.swift
- [ ] Features:
  - Asset info
  - Price chart
  - Edit/Delete

**Assigned to:** Can delegate to assistant

---

### **Phase 3: Market Feature** (3 hours)
**Status:** ⏳ Waiting for Phase 2

#### **Task 3.1: Market Service** (1 hour)
- [ ] Features/Market/Services/Market/MarketServiceProtocol.swift
- [ ] Features/Market/Services/Market/MarketService.swift
- [ ] Fetch real-time prices from CoinGecko

**Assigned to:** Can delegate to assistant

---

#### **Task 3.2: Market Screen** (2 hours)
- [ ] Features/Market/Screens/MarketScreen/MarketViewModel.swift
- [ ] Features/Market/Screens/MarketScreen/MarketScreen.swift
- [ ] Browse crypto prices
- [ ] Search
- [ ] Add to portfolio

**Assigned to:** Split (like Portfolio)

---

### **Phase 4: Settings & Polish** (2 hours)
**Status:** ⏳ Waiting for Phase 3

#### **Task 4.1: Settings** (1 hour)
- [ ] Features/Settings/Screens/SettingsScreen/SettingsScreen.swift
- [ ] Features/Settings/Screens/SettingsScreen/SettingsViewModel.swift
- [ ] Currency selection
- [ ] Theme (light/dark)
- [ ] About

**Assigned to:** Can delegate to assistant

---

#### **Task 4.2: Polish** (1 hour)
- [ ] Add app icon
- [ ] Splash screen
- [ ] Animations
- [ ] Final testing

**Assigned to:** You (design choices)

---

## 🎯 API Integration

### **CoinGecko API (Free)**

**Base URL:** `https://api.coingecko.com/api/v3`

**Endpoints we'll use:**
1. `/simple/price` - Get current prices
2. `/coins/markets` - Get market data
3. `/coins/{id}/market_chart` - Get price history

**No API key needed!** (Free tier: 50 calls/min)

---

## 📅 Timeline

### **Day 1 (Tomorrow):** Phase 1 + Start Phase 2
- Morning (9 AM - 12 PM): Setup + Base files
- Afternoon (2 PM - 6 PM): Portfolio models + service

### **Day 2:** Complete Phase 2
- Portfolio screens
- Testing

### **Day 3:** Phase 3
- Market feature

### **Day 4:** Phase 4 + Testing
- Settings
- Polish
- Final testing

**Total:** ~4 days for MVP

---

## 🚀 Getting Started (Tomorrow 9 AM)

### **Step 1: You do (30 min)**
1. Open Xcode
2. Create new project: CryptoPortfolio
3. Create folder structure

### **Step 2: I do (1 hour)**
1. Create all base files
2. Setup Git
3. Push to GitHub

### **Step 3: We do together**
1. Review architecture
2. Start Portfolio feature
3. Delegate remaining tasks

---

## 📊 Progress Tracking

### **Phase 1: Project Setup**
- [ ] Xcode project created
- [ ] Folder structure created
- [ ] Base files created
- [ ] Git initialized
- [ ] Pushed to GitHub

### **Phase 2: Portfolio Feature**
- [ ] Models created
- [ ] Service created
- [ ] Portfolio screen working
- [ ] Add asset working
- [ ] Detail screen working

### **Phase 3: Market Feature**
- [ ] Market service created
- [ ] Market screen working
- [ ] Price updates working

### **Phase 4: Settings & Polish**
- [ ] Settings working
- [ ] App icon added
- [ ] Polish complete

---

## 💡 Task Delegation Strategy

### **I Can Do (Assistant):**
- ✅ Create all base files (APIService, Theme, etc.)
- ✅ Write Models
- ✅ Write Services (with protocols)
- ✅ Write ViewModel logic
- ✅ Write basic View structure
- ✅ Git operations
- ✅ Documentation

### **You Should Do (You):**
- ✅ Create Xcode project (can't automate)
- ✅ Create folder structure in Xcode
- ✅ Customize UI appearance
- ✅ Choose colors/fonts
- ✅ Test on device
- ✅ Final polish decisions

### **We Do Together:**
- ✅ Architecture decisions (done! ✅)
- ✅ Feature planning
- ✅ Review code
- ✅ Bug fixes

---

## 🎯 Next Steps (Right Now)

### **Option A: Start Now (Quick setup)**
1. I create all base files
2. You create Xcode project tomorrow
3. Copy files into project

### **Option B: Start Tomorrow Morning**
1. Tomorrow 9 AM you create Xcode project
2. I help with base files live
3. Progress together

---

**What do you prefer?**
- **A** - I prepare files now (ready tomorrow)
- **B** - Start fresh tomorrow together

---

**Ready to build CryptoPortfolio!** 🚀

**Estimated completion:** 4 days  
**Cost:** ~$1-2 (mostly Qwen, some Kimi for complex stuff)
