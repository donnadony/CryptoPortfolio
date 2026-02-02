//
//  LanguageManager.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import SwiftUI
import Combine

/// Language manager for controlling app localization
/// Uses @Published currentLanguage to propagate changes through SwiftUI
@MainActor
final class LanguageManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = LanguageManager()
    
    // MARK: - Persisted Language
    
    @AppStorage("app_language") private var storedLanguage: String = Language.system.rawValue
    
    // MARK: - Published Properties
    
    /// Current language selection
    @Published var currentLanguage: Language = .system
    
    /// Locale to apply to the app
    @Published var currentLocale: Locale = .current
    
    /// Notification sent when language changes for views to refresh
    static let languageDidChangeNotification = Notification.Name("LanguageDidChangeNotification")
    
    // MARK: - Language Enum
    
    enum Language: String, CaseIterable, Identifiable, Sendable {

        case english = "en"
        case spanish = "es"
        case system = "sys"

        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .spanish: return "Español"
            case .system: return LocalizedKey.Settings.languageSystem.localized
            }
        }
        
        var localizedDisplayName: String {
            switch self {
            case .english: return LocalizedKey.Settings.languageEnglish.localized
            case .spanish: return LocalizedKey.Settings.languageSpanish.localized
            case .system: return LocalizedKey.Settings.languageSystem.localized
            }
        }
        
        var icon: String {
            switch self {
            case .english: return "🇺🇸"
            case .spanish: return "🇪🇸"
            case .system: return "⚙️"
            }
        }
        
        var code: String {
            switch self {
            case .english: return "en"
            case .spanish: return "es"
            case .system:
                let preferredLanguage = Locale.preferredLanguages.first ?? "en"
                if preferredLanguage.hasPrefix("es") { return "es" }
                return "en"
            }
        }
        
        var locale: Locale { Locale(identifier: code) }
        
        init?(code: String) {
            switch code {
            case "en": self = .english
            case "es": self = .spanish
            case "sys": self = .system
            default: return nil
            }
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        let language = Language(rawValue: storedLanguage) ?? .system
        currentLanguage = language
        currentLocale = language.locale
    }
    
    // MARK: - Public Methods
    
    /// Set the app language and persist the selection
    func setLanguage(_ language: Language) {
        currentLanguage = language
        storedLanguage = language.rawValue
        currentLocale = language.locale
        
        // Apply to UserDefaults for Apple frameworks
        UserDefaults.standard.set([language.code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Post notification for views to refresh
        NotificationCenter.default.post(
            name: Self.languageDidChangeNotification,
            object: nil,
            userInfo: ["language": language]
        )
        
        // Trigger SwiftUI refresh
        objectWillChange.send()
    }
    
    /// Cycle through available languages: system → english → spanish → system
    func cycleLanguage() {
        switch currentLanguage {
        case .system:
            setLanguage(.english)
        case .english:
            setLanguage(.spanish)
        case .spanish:
            setLanguage(.system)
        }
    }
    
    /// Get all available languages
    var availableLanguages: [Language] {
        Language.allCases
    }
    
    /// Get supported languages (excluding system)
    var supportedLanguages: [Language] {
        Language.allCases.filter { $0 != .system }
    }
    
    /// Check if a language is supported
    func isSupported(_ languageCode: String) -> Bool {
        Language(code: languageCode) != nil
    }
    
    /// Get display name for a language code
    func displayName(for languageCode: String) -> String {
        Language(code: languageCode)?.displayName ?? languageCode
    }
}

// MARK: - View Extension for Language Application

extension View {
    /// Apply the LanguageManager's locale to this view
    func applyLanguage(from languageManager: LanguageManager) -> some View {
        self.environment(\.locale, languageManager.currentLocale)
    }
    
    /// Observe language changes and refresh the view
    func onLanguageChange(perform action: @escaping (LanguageManager.Language) -> Void) -> some View {
        self.onReceive(
            NotificationCenter.default.publisher(for: LanguageManager.languageDidChangeNotification)
        ) { notification in
            if let language = notification.userInfo?["language"] as? LanguageManager.Language {
                action(language)
            }
        }
    }
}

// MARK: - Environment Key

private struct LanguageManagerKey: EnvironmentKey {
    static let defaultValue = LanguageManager.shared
}

extension EnvironmentValues {
    var languageManager: LanguageManager {
        get { self[LanguageManagerKey.self] }
        set { self[LanguageManagerKey.self] = newValue }
    }
}
