//
//  AnalyticsDashboardScreen.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 02/01/2026.
//

import SwiftUI

#if os(iOS)

/// Analytics dashboard showing portfolio performance metrics and insights
struct AnalyticsDashboardScreen: View {
    @StateObject private var viewModel: AnalyticsDashboardViewModel
    @StateObject private var router = AnalyticsRouter()
    
    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.makeAnalyticsDashboardViewModel())
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                AdaptiveMeshBackground()
                
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.lg) {
                        // Performance Overview Card
                        performanceCard
                        
                        // Allocation Chart Card
                        allocationCard
                        
                        // Top Performers Section
                        topPerformersSection
                        
                        // Quick Actions
                        quickActionsSection
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .analyticsNavigationDestinations(router: router)
            .task {
                await viewModel.loadAnalytics()
            }
            .refreshable {
                await viewModel.loadAnalytics()
            }
        }
        .environmentObject(router)
    }
    
    // MARK: - Performance Card
    
    private var performanceCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Performance")
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedTimeframe.displayName)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: AppTheme.Spacing.xl) {
                performanceMetric(
                    title: "Total Return",
                    value: viewModel.formattedTotalReturn,
                    isPositive: viewModel.isTotalReturnPositive
                )
                
                Divider()
                    .frame(height: 40)
                
                performanceMetric(
                    title: "24h Change",
                    value: viewModel.formatted24hChange,
                    isPositive: viewModel.is24hChangePositive
                )
            }
            
            // Timeframe Selector
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(AnalyticsTimeframe.allCases, id: \.self) { timeframe in
                    Button {
                        viewModel.selectTimeframe(timeframe)
                    } label: {
                        Text(timeframe.shortName)
                            .font(AppTheme.Typography.caption)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(
                                Capsule()
                                    .fill(viewModel.selectedTimeframe == timeframe
                                          ? AppTheme.Colors.primary
                                          : Color.clear)
                            )
                            .foregroundStyle(viewModel.selectedTimeframe == timeframe
                                             ? .white
                                             : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .liquidGlassCard()
    }
    
    private func performanceMetric(title: String, value: String, isPositive: Bool) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(AppTheme.Typography.title3)
                .fontWeight(.semibold)
                .foregroundStyle(isPositive ? AppTheme.Colors.success : AppTheme.Colors.error)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Allocation Card
    
    private var allocationCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Asset Allocation")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(.primary)
            
            if viewModel.allocations.isEmpty {
                Text("No assets to display")
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, AppTheme.Spacing.lg)
            } else {
                ForEach(viewModel.allocations) { allocation in
                    allocationRow(allocation)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .liquidGlassCard()
    }
    
    private func allocationRow(_ allocation: AssetAllocation) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            HStack {
                Text(allocation.symbol)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(allocation.formattedPercentage)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(allocation.color)
                        .frame(width: geometry.size.width * allocation.percentage / 100)
                }
            }
            .frame(height: 8)
        }
    }
    
    // MARK: - Top Performers Section
    
    private var topPerformersSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Top Performers (24h)")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(.primary)
            
            if viewModel.topPerformers.isEmpty {
                Text("No data available")
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, AppTheme.Spacing.md)
            } else {
                ForEach(viewModel.topPerformers) { performer in
                    HStack {
                        Text(performer.symbol)
                            .font(AppTheme.Typography.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: performer.isPositive ? "arrow.up.right" : "arrow.down.right")
                            Text(performer.formattedChange)
                        }
                        .font(AppTheme.Typography.subheadline)
                        .foregroundStyle(performer.isPositive ? AppTheme.Colors.success : AppTheme.Colors.error)
                    }
                    .padding(.vertical, AppTheme.Spacing.xs)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .liquidGlassCard()
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Quick Actions")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(.primary)
            
            HStack(spacing: AppTheme.Spacing.md) {
                quickActionButton(
                    icon: "square.and.arrow.up",
                    title: "Export",
                    action: { router.navigate(to: .export) }
                )
                
                quickActionButton(
                    icon: "chart.bar.xaxis",
                    title: "Compare",
                    action: { /* Future feature */ }
                )
                
                quickActionButton(
                    icon: "bell.badge",
                    title: "Alerts",
                    action: { /* Future feature */ }
                )
            }
        }
        .padding(AppTheme.Spacing.lg)
        .liquidGlassCard()
    }
    
    private func quickActionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(AppTheme.Colors.primary)
                
                Text(title)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(AppTheme.Colors.primary.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    AnalyticsDashboardScreen()
        .withContainer()
}

#endif
