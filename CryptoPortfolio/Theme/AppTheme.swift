//
//  AppTheme.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/2026.
//

import SwiftUI

// MARK: - App Theme

struct AppTheme {
    
    // MARK: - Colors (Adaptive)
    
    struct Colors {
        // Brand Colors
        static let primary = Color.brandPrimary
        static let secondary = Color.brandSecondary
        static let accent = Color.brandAccent
        
        // System Backgrounds (SwiftUI native)
        static let background = Color(red: 0.98, green: 0.98, blue: 0.98)
        static let secondaryBackground = Color(red: 0.95, green: 0.95, blue: 0.95)
        static let tertiaryBackground = Color(red: 0.93, green: 0.93, blue: 0.93)
        
        // Grouped Backgrounds
        static let groupedBackground = Color(red: 0.97, green: 0.97, blue: 1.0)
        static let groupedSecondary = Color.white
        
        // Adaptive Mesh Backgrounds
        static let meshBackground1 = Color.adaptiveBackground1
        static let meshBackground2 = Color.adaptiveBackground2
        static let meshBackground3 = Color.adaptiveBackground3
        
        // Glass Effect Colors (Adaptive)
        static let glassBackground = Color.glassBackground
        static let glassOverlay = Color.glassOverlay
        static let glassBorder = Color.glassBorder
        
        // Text Colors (High Contrast)
        static let textPrimary = Color.primaryText
        static let textSecondary = Color.secondaryText
        static let textTertiary = Color.tertiaryText
        
        // Status Colors
        static let success = Color.statusSuccess
        static let error = Color.statusError
        static let warning = Color.statusWarning
        static let info = Color.statusInfo
        
        // Chart Colors
        static let profitGreen = Color.chartProfit
        static let lossRed = Color.chartLoss
        static let neutralGray = Color.chartNeutral
    }
    
    // MARK: - Typography
    
    struct Typography {
        static let largeTitle = Font.system(size: 38, weight: .bold, design: .rounded)
        static let title = Font.system(size: 32, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 24, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
        
        // Monospaced for numbers
        static let monoTitle = Font.system(size: 28, weight: .semibold, design: .monospaced)
        static let monoHeadline = Font.system(size: 20, weight: .semibold, design: .monospaced)
        static let monoBody = Font.system(size: 17, weight: .regular, design: .monospaced)
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    struct CornerRadius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let full: CGFloat = 1000
    }
    
    // MARK: - Shadows (Adaptive)
    
    struct Shadows {
        static let small = Shadow(
            lightColor: Color.black.opacity(0.04),
            darkColor: Color.black.opacity(0.20),
            radius: 8,
            x: 0,
            y: 2
        )
        static let medium = Shadow(
            lightColor: Color.black.opacity(0.06),
            darkColor: Color.black.opacity(0.30),
            radius: 16,
            x: 0,
            y: 4
        )
        static let large = Shadow(
            lightColor: Color.black.opacity(0.08),
            darkColor: Color.black.opacity(0.40),
            radius: 24,
            x: 0,
            y: 8
        )
    }
    
    struct Shadow {
        let lightColor: Color
        let darkColor: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
        
        var color: Color {
            Color(
                light: lightColor,
                dark: darkColor
            )
        }
    }
}

// MARK: - Liquid Glass View Modifiers

extension View {
    func appShadow(_ shadow: AppTheme.Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    /// Liquid glass card - Adaptive for light/dark mode
    func liquidGlassCard(cornerRadius: CGFloat = AppTheme.CornerRadius.lg) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.Colors.glassBackground)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 0.5)
                    )
            )
            .appShadow(AppTheme.Shadows.medium)
    }
    
    /// Simple glass card without material
    func glassCard(cornerRadius: CGFloat = AppTheme.CornerRadius.lg) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.Colors.glassBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 0.5)
                    )
            )
            .appShadow(AppTheme.Shadows.small)
    }
    
    /// Floating glass pill
    func glassPill() -> some View {
        self
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                Capsule()
                    .fill(AppTheme.Colors.glassBackground)
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.Colors.glassBorder, lineWidth: 0.5)
                    )
            )
    }
    
    /// Primary action button
    func primaryButton() -> some View {
        self
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                Capsule()
                    .fill(AppTheme.Colors.primary)
            )
            .foregroundColor(.white)
            .appShadow(AppTheme.Shadows.small)
    }
}

// MARK: - Adaptive Background View

struct AdaptiveMeshBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base color
                AppTheme.Colors.meshBackground1
                
                // Soft gradient orbs
                Circle()
                    .fill(AppTheme.Colors.primary.opacity(colorScheme == .light ? 0.08 : 0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -100, y: -150)
                
                Circle()
                    .fill(AppTheme.Colors.secondary.opacity(colorScheme == .light ? 0.06 : 0.10))
                    .frame(width: 400, height: 400)
                    .blur(radius: 100)
                    .offset(x: 150, y: 250)
                
                // Additional subtle orb for light mode
                if colorScheme == .light {
                    Circle()
                        .fill(AppTheme.Colors.accent.opacity(0.05))
                        .frame(width: 250, height: 250)
                        .blur(radius: 60)
                        .offset(x: 80, y: -100)
                }
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    VStack(spacing: AppTheme.Spacing.lg) {
        Text("Liquid Glass Card")
            .font(AppTheme.Typography.title3)
            .liquidGlassCard()
        
        Text("Glass Pill")
            .font(AppTheme.Typography.callout)
            .glassPill()
        
        Text("Primary Button")
            .font(AppTheme.Typography.headline)
            .primaryButton()
    }
    .padding()
    .background(AdaptiveMeshBackground())
}

#Preview("Dark Mode") {
    VStack(spacing: AppTheme.Spacing.lg) {
        Text("Liquid Glass Card")
            .font(AppTheme.Typography.title3)
            .liquidGlassCard()
        
        Text("Glass Pill")
            .font(AppTheme.Typography.callout)
            .glassPill()
        
        Text("Primary Button")
            .font(AppTheme.Typography.headline)
            .primaryButton()
    }
    .padding()
    .background(AdaptiveMeshBackground())
    .preferredColorScheme(.dark)
}
