# Coding Notes - CryptoPortfolio 📝

**Important coding patterns and best practices for this project**

---

## ✅ **ALWAYS Remember**

### **1. ObservableObject → import Combine**

**ALWAYS add `import Combine` when using `ObservableObject`:**

```swift
import Foundation
import Combine  // ✅ REQUIRED for ObservableObject

@MainActor
class MyViewModel: ObservableObject {
    @Published var data: String = ""
}
```

**Why:**
- `ObservableObject` is part of Combine framework
- `@Published` also requires Combine
- Best practice even if SwiftUI imports it implicitly

---

### **2. ViewModels Always @MainActor**

```swift
@MainActor  // ✅ ALWAYS for ViewModels
class MyViewModel: ObservableObject {
    // UI updates happen on main thread
}
```

---

### **3. Services Use Protocols**

```swift
// ✅ Protocol first
protocol MyServiceProtocol {
    func fetch() async throws -> Data
}

// ✅ Implementation
class MyService: MyServiceProtocol {
    func fetch() async throws -> Data { }
}
```

---

### **4. Dependency Injection in Init**

```swift
// ✅ Protocol-based injection
class MyViewModel: ObservableObject {
    private let service: MyServiceProtocol
    
    init(service: MyServiceProtocol = MyService()) {
        self.service = service
    }
}
```

---

### **5. Async/Await (No Completion Handlers)**

```swift
// ✅ Modern async/await
func loadData() async {
    do {
        let data = try await service.fetch()
    } catch {
        // handle error
    }
}

// ❌ Old completion handlers
func loadData(completion: @escaping (Result<Data, Error>) -> Void) {
    // Don't use this pattern
}
```

---

### **6. Architecture Rules**

**Services:**
```
Features/[Feature]/Services/[Feature]/
├── [Feature]ServiceProtocol.swift  ✅ Protocol in separate file
└── [Feature]Service.swift          ✅ Implementation in separate file
```

**Screens:**
```
Features/[Feature]/Screens/[Screen]Screen/
├── [Screen]Screen.swift      ✅ View in separate file
└── [Screen]ViewModel.swift   ✅ ViewModel in separate file
```

---

## 📋 **Pre-Flight Checklist for New Files**

Before creating any new Swift file:

**ViewModels:**
- [ ] `import Foundation`
- [ ] `import Combine` ✅ IMPORTANT
- [ ] `@MainActor`
- [ ] `: ObservableObject`
- [ ] `@Published` properties
- [ ] Protocol-based service injection

**Services:**
- [ ] Create protocol first
- [ ] Protocol in separate file
- [ ] Implementation in separate file
- [ ] Async/await methods
- [ ] Error handling
- [ ] Dependency injection via init

**Views:**
- [ ] `import SwiftUI`
- [ ] `@StateObject` for ViewModel
- [ ] Loading states
- [ ] Error states
- [ ] Empty states

---

## 🎯 **Common Patterns**

### **ViewModel Pattern:**

```swift
import Foundation
import Combine  // ✅

@MainActor
class FeatureViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var data: [Item] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // MARK: - Dependencies
    private let service: FeatureServiceProtocol
    
    // MARK: - Initialization
    init(service: FeatureServiceProtocol = FeatureService()) {
        self.service = service
    }
    
    // MARK: - Public Methods
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            data = try await service.fetchData()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
```

### **Service Pattern:**

```swift
// Protocol
protocol FeatureServiceProtocol {
    func fetchData() async throws -> [Item]
}

// Implementation
class FeatureService: FeatureServiceProtocol {
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }
    
    func fetchData() async throws -> [Item] {
        try await apiService.request(
            endpoint: "/data",
            method: .get
        )
    }
}
```

---

## 🚫 **Don't Do This**

### **❌ Missing Combine Import**
```swift
import Foundation
// ❌ Missing: import Combine

@MainActor
class MyViewModel: ObservableObject {  // Will work but not best practice
    @Published var data: String = ""
}
```

### **❌ No @MainActor**
```swift
// ❌ Missing @MainActor
class MyViewModel: ObservableObject {
    @Published var data: String = ""  // Potential threading issues
}
```

### **❌ Direct Service Instantiation**
```swift
// ❌ Can't test or mock
class MyViewModel: ObservableObject {
    private let service = MyService()  // Hard-coded dependency
}
```

### **❌ Completion Handlers**
```swift
// ❌ Old pattern
func loadData(completion: @escaping (Result<Data, Error>) -> Void) {
    service.fetch { result in
        completion(result)
    }
}
```

---

## ✅ **Fixed Issues Log**

### **Issue #1: Missing Combine Import**
- **Date:** January 31, 2026
- **Files:** PortfolioViewModel.swift, AssetDetailViewModel.swift
- **Fix:** Added `import Combine`
- **Lesson:** Always import Combine for ObservableObject

---

## 📚 **Quick Reference**

**Common Imports:**

```swift
// ViewModels
import Foundation
import Combine

// Views
import SwiftUI

// Services
import Foundation

// Models
import Foundation
```

**Common Protocols:**

- `ObservableObject` → Requires Combine
- `Codable` → Built-in, no import needed
- `Identifiable` → Built-in, no import needed

---

## 🎯 **When Creating New Feature**

1. ✅ Read this file first
2. ✅ Create protocol-based service
3. ✅ Import Combine in ViewModels
4. ✅ Use @MainActor for ViewModels
5. ✅ Async/await everywhere
6. ✅ Proper error handling
7. ✅ Follow architecture rules

---

**Updated:** January 31, 2026  
**Keep this file updated with new patterns and fixes!**
