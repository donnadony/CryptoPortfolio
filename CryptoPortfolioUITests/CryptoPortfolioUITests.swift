//
//  CryptoPortfolioUITests.swift
//  CryptoPortfolioUITests
//
//  Screenshot tests using fastlane snapshot.
//  The app is launched with UI_TEST_MODE so it uses offline mock data —
//  no network calls, no timeouts, instant data.
//

import XCTest

final class CryptoPortfolioUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Tell the app to use mock data (handled in Container.swift)
        app.launchArguments = ["UI_TEST_MODE", "MOCK_DATA_ENABLED"]
        app.launchEnvironment = ["SNAPSHOT_TEST": "1"]
        setupSnapshot(app)
        app.launch()
        // Give the app a moment to render with mock data
        sleep(2)
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Screenshot Tests

    @MainActor
    func testScreenshotsLight() throws {
        captureAllScreenshots(suffix: "light")
    }

    @MainActor
    func testScreenshotsDark() throws {
        captureAllScreenshots(suffix: "dark")
    }

    // MARK: - Helpers

    @MainActor
    private func captureAllScreenshots(suffix: String) {
        let tabBar = app.tabBars.firstMatch

        // 1. Portfolio tab (first / default)
        snapshot("01_portfolio_\(suffix)")

        // 2. Market tab
        tapTabIfExists(in: tabBar, names: ["Market", "Mercado", "market"])
        sleep(1)
        snapshot("02_market_\(suffix)")

        // 3. Analytics tab
        tapTabIfExists(in: tabBar, names: ["Analytics", "Analítica", "analytics"])
        sleep(1)
        snapshot("03_analytics_\(suffix)")

        // 4. Watchlist tab
        tapTabIfExists(in: tabBar, names: ["Watchlist", "Lista", "watchlist"])
        sleep(1)
        snapshot("04_watchlist_\(suffix)")

        // 5. Settings tab
        tapTabIfExists(in: tabBar, names: ["Settings", "Ajustes", "settings"])
        sleep(1)
        snapshot("05_settings_\(suffix)")

        // 6. Back to Portfolio — tap first asset for detail
        tapTabIfExists(in: tabBar, names: ["Portfolio", "Portafolio", "portfolio"])
        sleep(1)
        let firstCell = app.cells.firstMatch
        if firstCell.exists && firstCell.isHittable {
            firstCell.tap()
            sleep(1)
            snapshot("06_asset_detail_\(suffix)")
            app.navigationBars.buttons.firstMatch.tap()
        }
    }

    private func tapTabIfExists(in tabBar: XCUIElement, names: [String]) {
        for name in names {
            let button = tabBar.buttons[name]
            if button.exists && button.isHittable {
                button.tap()
                return
            }
        }
        // Fallback: try any button that partially matches
        for name in names {
            let button = tabBar.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", name)).firstMatch
            if button.exists && button.isHittable {
                button.tap()
                return
            }
        }
    }
}
