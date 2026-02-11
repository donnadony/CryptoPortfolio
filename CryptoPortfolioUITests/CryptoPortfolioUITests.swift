//
//  CryptoPortfolioUITests.swift
//  CryptoPortfolioUITests
//
//  Created by Donnadony Mollo on 31/01/26.
//

import XCTest

final class CryptoPortfolioUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Enable UI testing mode and mock data
        app.launchArguments = ["UI_TEST_MODE", "MOCK_DATA_ENABLED"]
        app.launchEnvironment = [
            "SNAPSHOT_TEST": "1",
            "MOCK_PORTFOLIO": "1"
        ]
        
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Screenshot Tests: Light Mode
    
    @MainActor
    func testScreenshotsLight() throws {
        // Setup snapshot helper
        setupSnapshot(app)
        
        // Wait for app to load with mock data
        sleep(2)
        
        let tabBar = app.tabBars["Tab Bar"]
        
        // ============================================
        // 1. Portfolio Tab - Light Mode
        // ============================================
        snapshot("01_portfolio_light")
        
        // ============================================
        // 2. Market Tab - Light Mode
        // ============================================
        tabBar.buttons["Market"].tap()
        sleep(1)
        snapshot("02_market_light")
        
        // ============================================
        // 3. Analytics Tab - Light Mode
        // ============================================
        tabBar.buttons["Analytics"].tap()
        sleep(1)
        snapshot("03_analytics_light")
        
        // ============================================
        // 4. Watchlist Tab - Light Mode
        // ============================================
        tabBar.buttons["Watchlist"].tap()
        sleep(1)
        snapshot("04_watchlist_light")
        
        // ============================================
        // 5. Settings Tab - Light Mode
        // ============================================
        tabBar.buttons["Settings"].tap()
        sleep(1)
        snapshot("05_settings_light")
        
        // Go back to Portfolio
        tabBar.buttons["Portfolio"].tap()
    }
    
    // MARK: - Screenshot Tests: Dark Mode
    
    @MainActor
    func testScreenshotsDark() throws {
        // Setup snapshot helper
        setupSnapshot(app)
        
        // Wait for app to load
        sleep(2)
        
        let tabBar = app.tabBars["Tab Bar"]
        
        // Navigate to Settings to enable dark mode
        tabBar.buttons["Settings"].tap()
        sleep(1)
        
        // Toggle dark mode if available
        let darkModeSwitch = app.switches["Dark Mode"]
        if darkModeSwitch.exists {
            darkModeSwitch.tap()
            sleep(1)
        }
        
        // ============================================
        // 1. Portfolio Tab - Dark Mode
        // ============================================
        tabBar.buttons["Portfolio"].tap()
        sleep(1)
        snapshot("01_portfolio_dark")
        
        // ============================================
        // 2. Market Tab - Dark Mode
        // ============================================
        tabBar.buttons["Market"].tap()
        sleep(1)
        snapshot("02_market_dark")
        
        // ============================================
        // 3. Analytics Tab - Dark Mode
        // ============================================
        tabBar.buttons["Analytics"].tap()
        sleep(1)
        snapshot("03_analytics_dark")
        
        // ============================================
        // 4. Watchlist Tab - Dark Mode
        // ============================================
        tabBar.buttons["Watchlist"].tap()
        sleep(1)
        snapshot("04_watchlist_dark")
        
        // ============================================
        // 5. Settings Tab - Dark Mode
        // ============================================
        tabBar.buttons["Settings"].tap()
        sleep(1)
        snapshot("05_settings_dark")
        
        // Reset to light mode
        if darkModeSwitch.exists {
            darkModeSwitch.tap()
        }
    }
    
    // MARK: - Existing UI Tests
    
    @MainActor
    func testNavigateAllTabs() throws {
        let tabBar = app.tabBars["Tab Bar"]
        
        // Navigate to Market tab
        tabBar.buttons["Market"].tap()
        XCTAssertTrue(app.staticTexts["Market"].exists || app.navigationBars["Market"].exists)
        
        // Navigate to Analytics tab
        tabBar.buttons["Analytics"].tap()
        XCTAssertTrue(app.staticTexts["Analytics"].exists || app.navigationBars["Analytics"].exists)
        
        // Navigate to Watchlist tab
        tabBar.buttons["Watchlist"].tap()
        XCTAssertTrue(app.staticTexts["Watchlist"].exists || app.navigationBars["Watchlist"].exists)
        
        // Navigate to Settings tab
        tabBar.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].exists || app.navigationBars["Settings"].exists)
        
        // Back to Portfolio
        tabBar.buttons["Portfolio"].tap()
        XCTAssertTrue(app.staticTexts["Portfolio"].exists || app.navigationBars["Portfolio"].exists)
    }
    
    @MainActor
    func testDarkModeToggle() throws {
        // Navigate to Settings
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Settings"].tap()
        
        // Tap on Appearance toggle
        let appearanceToggle = app.switches["Dark Mode"]
        if appearanceToggle.exists {
            appearanceToggle.tap()
            sleep(1)
            // Toggle back
            appearanceToggle.tap()
        }
    }
    
    @MainActor
    func testLanguageChange() throws {
        // Navigate to Settings
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Settings"].tap()
        
        // Tap on Language
        if app.buttons["Language"].exists {
            app.buttons["Language"].tap()
            
            // Select Spanish if available
            if app.buttons["Español"].waitForExistence(timeout: 2) {
                app.buttons["Español"].tap()
                sleep(2)
                
                // Go back to Portfolio and verify language change
                tabBar.buttons["Portfolio"].tap()
            }
        }
    }
    
    // MARK: - Additional Screenshot: Portfolio Detail
    
    @MainActor
    func testPortfolioDetailScreenshot() throws {
        setupSnapshot(app)
        
        // Wait for app to load
        sleep(2)
        
        // Try to tap on first portfolio item if exists
        let firstCell = app.cells.element(boundBy: 0)
        if firstCell.exists {
            firstCell.tap()
            sleep(1)
            snapshot("06_portfolio_detail_light")
            
            // Go back
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }
    
    // MARK: - Additional Screenshot: Add Asset Screen
    
    @MainActor
    func testAddAssetScreenshot() throws {
        setupSnapshot(app)
        
        // Wait for app to load
        sleep(2)
        
        // Look for add button
        var addButton = app.buttons["Add"]
        if !addButton.exists {
            addButton = app.navigationBars.buttons["+"]
        }
        if addButton.exists {
            addButton.tap()
            sleep(1)
            snapshot("07_add_asset_light")
            
            // Cancel
            if app.buttons["Cancel"].exists {
                app.buttons["Cancel"].tap()
            }
        }
    }
}