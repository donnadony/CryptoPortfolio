# Swift Concurrency Fixes 🔧

**Soluciones para errores de actor isolation en CryptoPortfolio**

Creado: January 31, 2026

---

## ⚠️ Error Común

```
Call to main actor-isolated initializer 'init(...)' in a synchronous nonisolated context
```

---

## 🎯 Solución: `nonisolated init` en Services

### **El Problema:**

```swift
// ViewModel es @MainActor
@MainActor
class PortfolioViewModel: ObservableObject {
    private let service: PortfolioServiceProtocol
    
    // init() llama a PortfolioService() como default
    init(service: PortfolioServiceProtocol = PortfolioService()) {  // ❌ Error
        self.service = service
    }
}

// Service sin nonisolated
class PortfolioService: PortfolioServiceProtocol {
    init(apiService: APIServiceProtocol = APIService.shared) {  // ❌ Problema
        self.apiService = apiService
    }
}
```

**Error:** El init del service es llamado desde un contexto @MainActor (el init del ViewModel), pero el service init no está marcado como compatible.

---

## ✅ La Solución:

```swift
// Service con nonisolated init
class PortfolioService: PortfolioServiceProtocol {
    nonisolated init(  // ✅ Puede ser llamado desde cualquier contexto
        apiService: APIServiceProtocol = APIService.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.apiService = apiService
        self.userDefaults = userDefaults
    }
    
    // Métodos async funcionan normalmente
    func fetchAssets() async throws -> [Asset] {
        // ...
    }
}
```

---

## 📋 Checklist para Services

Cuando crees un nuevo Service:

- [ ] Service class NO tiene `@MainActor`
- [ ] Init del service tiene `nonisolated`
- [ ] Métodos son `async` (no necesitan @MainActor)
- [ ] ViewModels que usan el service SÍ tienen `@MainActor`

---

## 💡 ¿Por Qué Funciona?

### **Actor Isolation en la App:**

| Componente | Actor | Razón |
|------------|-------|-------|
| **ViewModels** | `@MainActor` | Manejan UI state |
| **Services** | No isolated | Solo hacen network/storage |
| **Service init** | `nonisolated` | Permite crear desde cualquier actor |
| **Service methods** | `async` | Pueden cruzar actor boundaries |

### **Flujo:**

```
@MainActor ViewModel.init()
    ↓
Llama a: PortfolioService()  (default parameter)
    ↓
nonisolated init permite esto ✅
    ↓
ViewModel guarda referencia al service
    ↓
Cuando llama a service.fetchAssets() (async)
    ↓
Swift maneja el actor switching automáticamente ✅
```

---

## 🔧 Aplicado en CryptoPortfolio

### **Archivos Modificados:**

**1. PortfolioService.swift**
```swift
class PortfolioService: PortfolioServiceProtocol {
    nonisolated init(  // ✅ Agregado
        apiService: APIServiceProtocol = APIService.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.apiService = apiService
        self.userDefaults = userDefaults
    }
}
```

**Usado por:**
- PortfolioViewModel
- AddAssetViewModel
- AssetDetailViewModel

---

## 🎯 Pattern para Futuros Proyectos

### **Service Template:**

```swift
// Service Protocol
protocol MyServiceProtocol {
    func fetchData() async throws -> [Item]
}

// Service Implementation
class MyService: MyServiceProtocol {
    private let apiService: APIServiceProtocol
    
    // ✅ SIEMPRE nonisolated init
    nonisolated init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }
    
    // ✅ Métodos async (no @MainActor)
    func fetchData() async throws -> [Item] {
        try await apiService.request(endpoint: "/data", method: .get)
    }
}
```

### **ViewModel Template:**

```swift
// ✅ ViewModel con @MainActor
@MainActor
class MyViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    
    private let service: MyServiceProtocol
    
    // ✅ Init normal (MainActor context)
    init(service: MyServiceProtocol = MyService()) {
        self.service = service
    }
    
    // ✅ Métodos async
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            items = try await service.fetchData()
        } catch {
            // Handle error
        }
    }
}
```

---

## ❌ No Hacer Esto

### **1. @MainActor en Service**
```swift
// ❌ MAL - Service no necesita MainActor
@MainActor
class MyService: MyServiceProtocol {
    // Esto fuerza todos los métodos a MainActor (innecesario)
}
```

### **2. Sin nonisolated en init**
```swift
// ❌ MAL - Causa el error
class MyService {
    init() {  // No nonisolated
        // ...
    }
}
```

### **3. Completion Handlers en vez de async/await**
```swift
// ❌ VIEJO - No uses esto
func fetchData(completion: @escaping (Result<[Item], Error>) -> Void) {
    // ...
}
```

---

## 📚 Referencias

**Swift Concurrency:**
- [Swift.org - Actor Isolation](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [MainActor Documentation](https://developer.apple.com/documentation/swift/mainactor)
- [nonisolated Documentation](https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#grammar_nonisolated-modifier)

---

## ✅ Resumen

**Para evitar el error en futuros proyectos:**

1. ✅ ViewModels: `@MainActor class ViewModel: ObservableObject`
2. ✅ Services: `class Service: ServiceProtocol` (NO @MainActor)
3. ✅ Service init: `nonisolated init(...)`
4. ✅ Service methods: `async func`
5. ✅ Siempre usa `async/await` (no completion handlers)

**¡Copia este pattern y no tendrás problemas de concurrencia!** 🎯

---

**Actualizado:** January 31, 2026  
**Proyecto:** CryptoPortfolio
