//
//  ScreenshotCaptureTests.swift
//  CryptoPortfolioUITests
//
//  Created by Screenshot Generator on 02/02/26.
//

import XCTest

final class ScreenshotCaptureTests: XCTestCase {
    
    var app: XCUIApplication!
    let screenshotsDir = "/Users/donnadony/Documents/personal/CryptoPortfolio/fastlane/screenshots"
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TEST_MODE", "MOCK_DATA_ENABLED"]
        app.launchEnvironment = [
            "SNAPSHOT_TEST": "1",
            "MOCK_PORTFOLIO": "1"
        ]
        
        // Create screenshots directory
        let fileManager = FileManager.default
        try? fileManager.createDirectory(atPath: "\(screenshotsDir)/light", withIntermediateDirectories: true)
        try? fileManager.createDirectory(atPath: "\(screenshotsDir)/dark", withIntermediateDirectories: true)
        
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    // MARK: - Screenshot Helper
    
    func captureScreenshot(name: String, mode: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let path = "\(screenshotsDir)/\(mode)/\(name).png"
        
        do {
            try screenshot.pngRepresentation.write(to: URL(fileURLWithPath: path))
            print("✅ Screenshot saved: \(path)")
        } catch {
            print("❌ Failed to save screenshot: \(error)")
        }
    }
    
    // MARK: - Light Mode Screenshots
    
    @MainActor
    func test01_Portfolio_Light() throws {
        sleep(2) // Wait for app to load
        captureScreenshot(name: "01_portfolio", mode: "light")
    }
    
    @MainActor
    func test02_Market_Light() throws {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Market"].tap()
        sleep(1)
        captureScreenshot(name: "02_market", mode: "light")
    }
    
    @MainActor
    func test03_Analytics_Light() throws {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Analytics"].tap()
        sleep(1)
        captureScreenshot(name: "03_analytics", mode: "light")
    }
    
    @MainActor
    func test04_Watchlist_Light() throws {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Watchlist"].tap()
        sleep(1)
        captureScreenshot(name: "04_watchlist", mode: "light")
    }
    
    @MainActor
    func test05_Settings_Light() throws {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Settings"].tap()
        sleep(1)
        captureScreenshot(name: "05_settings", mode: "light")
    }
    
    // MARK: - Dark Mode Screenshots
    
    @MainActor
    func test06_Portfolio_Dark() throws {
        // Enable dark mode via settings
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Settings"].tap()
        sleep(1)
        
        // Toggle dark mode if available
        let darkModeSwitch = app.switches["Dark Mode"]
        if darkModeSwitch.exists {
            darkModeSwitch.tap()
            sleep(1)
        }
        
        // Go to portfolio and capture
        tabBar.buttons["Portfolio"].tap()
        sleep(1)
        captureScreenshot(name: "01_portfolio", mode: "dark")
    }
    
    @MainActor
    func test07_Market_Dark() throws {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Market"].tap()
        sleep(1)
        captureScreenshot(name: "02_market", mode: "dark")
    }
    
    @MainActor
    func test08_Analytics_Dark() throws {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Analytics"].tap()
        sleep(1)
        captureScreenshot(name: "03_analytics", mode: "dark")
    }
    
    @MainActor
    func test09_Watchlist_Dark() throws {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Watchlist"].tap()
        sleep(1)
        captureScreenshot(name: "04_watchlist", mode: "dark")
    }
    
    @MainActor
    func test10_Settings_Dark() throws {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Settings"].tap()
        sleep(1)
        captureScreenshot(name: "05_settings", mode: "dark")
        
        // Reset to light mode
        let darkModeSwitch = app.switches["Dark Mode"]
        if darkModeSwitch.exists {
            darkModeSwitch.tap()
        }
    }
}
