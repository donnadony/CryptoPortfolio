//
//  Color+Extensions.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import SwiftUI

// MARK: - Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Brand Colors (High Contrast)

extension Color {
    /// Bitcoin Orange - Vibrant
    static let brandPrimary = Color(hex: "#F7931A")
    /// Ethereum Blue - Deep
    static let brandSecondary = Color(hex: "#627EEA")
    /// Modern Teal - Bright
    static let brandAccent = Color(hex: "#00C9A7")
}

// MARK: - Status Colors (WCAG AA Compliant)

extension Color {
    /// Success Green - Darker for better contrast on light bg
    static let statusSuccess = Color(hex: "#059669")
    /// Error Red - Vibrant
    static let statusError = Color(hex: "#DC2626")
    /// Warning Orange - Accessible
    static let statusWarning = Color(hex: "#D97706")
    /// Info Blue - Clear
    static let statusInfo = Color(hex: "#2563EB")
}

// MARK: - Chart Colors

extension Color {
    static let chartProfit = Color(hex: "#059669")
    static let chartLoss = Color(hex: "#DC2626")
    static let chartNeutral = Color(hex: "#6B7280")
}

// MARK: - Adaptive Background Colors

extension Color {
    /// Light: Very light gray, Dark: Deep navy
    static var adaptiveBackground1: Color {
        Color(
            light: Color(hex: "#F8FAFC"),  // Slate 50
            dark: Color(hex: "#0F172A")     // Slate 900
        )
    }
    
    /// Light: Soft white, Dark: Dark blue-gray
    static var adaptiveBackground2: Color {
        Color(
            light: Color(hex: "#F1F5F9"),  // Slate 100
            dark: Color(hex: "#1E293B")     // Slate 800
        )
    }
    
    /// Light: Light gray-blue, Dark: Medium slate
    static var adaptiveBackground3: Color {
        Color(
            light: Color(hex: "#E2E8F0"),  // Slate 200
            dark: Color(hex: "#334155")     // Slate 700
        )
    }
}

// MARK: - Glass Effect Colors (Adaptive)

extension Color {
    /// Light: White 80% opacity, Dark: White 15% opacity
    static var glassBackground: Color {
        Color(
            light: Color.white.opacity(0.80),
            dark: Color.white.opacity(0.15)
        )
    }
    
    /// Light: Gray with opacity, Dark: Black with opacity
    static var glassOverlay: Color {
        Color(
            light: Color(hex: "#F1F5F9").opacity(0.90),
            dark: Color.black.opacity(0.20)
        )
    }
    
    /// Border for glass - Light: Gray, Dark: White tint
    static var glassBorder: Color {
        Color(
            light: Color(hex: "#CBD5E1").opacity(0.50),  // Slate 300
            dark: Color.white.opacity(0.25)
        )
    }
    
    /// Text on glass - Light: Dark, Dark: Light
    static var glassText: Color {
        Color(
            light: Color(hex: "#1E293B"),  // Slate 800
            dark: Color.white
        )
    }
}

// MARK: - Semantic Colors

extension Color {
    /// Primary text - High contrast
    static var primaryText: Color {
        Color(
            light: Color(hex: "#0F172A"),  // Slate 900
            dark: Color.white
        )
    }
    
    /// Secondary text - Medium contrast
    static var secondaryText: Color {
        Color(
            light: Color(hex: "#475569"),  // Slate 600
            dark: Color(hex: "#94A3B8")     // Slate 400
        )
    }
    
    /// Tertiary text - Low contrast
    static var tertiaryText: Color {
        Color(
            light: Color(hex: "#94A3B8"),  // Slate 400
            dark: Color(hex: "#64748B")     // Slate 500
        )
    }
}

// MARK: - Gradient Colors (Adaptive)

extension Color {
    /// Mesh gradient start - Light: Soft orange, Dark: Deep orange
    static var meshGradientStart: Color {
        Color(
            light: Color(hex: "#FED7AA").opacity(0.60),  // Orange 200
            dark: Color(hex: "#F7931A").opacity(0.30)
        )
    }
    
    /// Mesh gradient middle - Light: Soft blue, Dark: Deep blue
    static var meshGradientMiddle: Color {
        Color(
            light: Color(hex: "#BFDBFE").opacity(0.50),  // Blue 200
            dark: Color(hex: "#1E293B")
        )
    }
    
    /// Mesh gradient end - Light: Soft gray, Dark: Deep navy
    static var meshGradientEnd: Color {
        Color(
            light: Color(hex: "#E2E8F0").opacity(0.60),  // Slate 200
            dark: Color(hex: "#0F172A")
        )
    }
}

// MARK: - Environment-based Color Init

extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(
            light: UIColor(light),
            dark: UIColor(dark)
        ))
    }
}

extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        }
    }
}
