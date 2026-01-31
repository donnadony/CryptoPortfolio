# How to Add Base Files to Xcode 📦

**All base files are ready in the BaseFiles/ folder!**

Location: `~/Documents/Personal/CryptoPortfolio/BaseFiles/`

---

## 📂 Folder Structure in Xcode

First, create these groups (folders) in Xcode:

```
CryptoPortfolio/
├── App/
├── Core/
│   ├── Network/
│   ├── Storage/
│   └── Utils/
├── Features/
├── Shared/
│   ├── Components/
│   └── Extensions/
├── Navigation/
└── Theme/
```

**How to create groups:**
1. Right-click "CryptoPortfolio" in Xcode navigator
2. Select "New Group"
3. Name it (e.g., "App")
4. Repeat for all folders above

---

## 📝 Files to Add

### **Step 1: Add to App/**

1. Right-click **App/** folder in Xcode
2. Add Files to "CryptoPortfolio"...
3. Navigate to: `BaseFiles/App/`
4. Select: **RootView.swift**
5. Make sure "Copy items if needed" is ✅
6. Click "Add"

---

### **Step 2: Add to Core/Network/**

1. Right-click **Core/Network/** in Xcode
2. Add Files...
3. Navigate to: `BaseFiles/Core/Network/`
4. Select ALL 4 files:
   - HTTPMethod.swift
   - NetworkError.swift
   - APIConfig.swift
   - APIService.swift
5. ✅ "Copy items if needed"
6. Click "Add"

---

### **Step 3: Add to Core/Utils/**

1. Right-click **Core/Utils/**
2. Add Files...
3. Navigate to: `BaseFiles/Core/Utils/`
4. Select: **Constants.swift**
5. ✅ "Copy items if needed"
6. Click "Add"

---

### **Step 4: Add to Theme/**

1. Right-click **Theme/**
2. Add Files...
3. Navigate to: `BaseFiles/Theme/`
4. Select: **AppTheme.swift**
5. ✅ "Copy items if needed"
6. Click "Add"

---

### **Step 5: Add to Navigation/**

1. Right-click **Navigation/**
2. Add Files...
3. Navigate to: `BaseFiles/Navigation/`
4. Select BOTH files:
   - Route.swift
   - Router.swift
5. ✅ "Copy items if needed"
6. Click "Add"

---

### **Step 6: Add to Shared/Extensions/**

1. Right-click **Shared/Extensions/**
2. Add Files...
3. Navigate to: `BaseFiles/Shared/Extensions/`
4. Select BOTH files:
   - Color+Extensions.swift
   - View+Extensions.swift
5. ✅ "Copy items if needed"
6. Click "Add"

---

## ✏️ Update App Entry Point

1. **Open:** `CryptoPortfolioApp.swift` (in App/ folder)
2. **Replace the body with:**

```swift
var body: some Scene {
    WindowGroup {
        RootView()
    }
}
```

3. **Delete:** ContentView.swift (not needed)
4. **Delete:** Item.swift (not needed)

---

## ✅ Verify Setup

After adding all files:

1. **Press ⌘ + B** to build
2. Should compile successfully! ✅
3. **Press ⌘ + R** to run
4. Should see "CryptoPortfolio" text on screen

---

## 📋 Checklist

- [ ] Created folder structure in Xcode
- [ ] Added RootView.swift to App/
- [ ] Added 4 files to Core/Network/
- [ ] Added Constants.swift to Core/Utils/
- [ ] Added AppTheme.swift to Theme/
- [ ] Added 2 files to Navigation/
- [ ] Added 2 files to Shared/Extensions/
- [ ] Updated CryptoPortfolioApp.swift
- [ ] Deleted ContentView.swift
- [ ] Deleted Item.swift
- [ ] Project builds successfully (⌘ + B)
- [ ] Project runs (⌘ + R)

---

## 🎯 What's Next?

After base files are added and building:

1. **Message in Telegram:** "Base files added! Building successfully!"
2. **Next:** We'll create the Portfolio feature:
   - Models/Asset.swift
   - Services/Portfolio/
   - Screens/PortfolioScreen/

---

## 💡 Tips

**If you get build errors:**
- Make sure all files are in the correct groups
- Check that "Copy items if needed" was checked
- Try cleaning (⌘ + Shift + K) then building again

**Need help?**
- Screenshot the error
- Send it in Telegram
- I'll help immediately!

---

**Total time:** ~20 minutes to add all files ⏱️  
**Result:** Complete base architecture ready! ✅
