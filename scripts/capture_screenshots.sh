#!/bin/bash

# CryptoPortfolio Screenshot Generator Script
# Uses XCUITest with xcrun simctl for screenshot capture

set -e

PROJECT_DIR="/Users/donnadony/Documents/personal/CryptoPortfolio"
BUILD_DIR="$PROJECT_DIR/build"
SCREENSHOTS_DIR="$PROJECT_DIR/fastlane/screenshots"
SIMULATOR_ID="E7F05F76-2332-4118-BD0D-3095E5D7C302"

echo "========================================="
echo "CryptoPortfolio Screenshot Generator"
echo "========================================="

# Create output directories
mkdir -p "$SCREENSHOTS_DIR/light"
mkdir -p "$SCREENSHOTS_DIR/dark"

# Kill any existing simulator
echo "[1/8] Cleaning up existing simulator sessions..."
xcrun simctl shutdown "$SIMULATOR_ID" 2>/dev/null || true
sleep 2

# Boot simulator
echo "[2/8] Booting iPhone 15 Pro simulator..."
xcrun simctl boot "$SIMULATOR_ID"
sleep 5

# Wait for simulator to be ready
echo "[3/8] Waiting for simulator to be ready..."
until xcrun simctl list devices | grep "$SIMULATOR_ID" | grep -q "Booted"; do
    sleep 1
done
echo "Simulator is ready!"

# Install the app
echo "[4/8] Installing app on simulator..."
xcrun simctl install "$SIMULATOR_ID" "$BUILD_DIR/Build/Products/Debug-iphonesimulator/CryptoPortfolio.app"
sleep 2

# Launch app with mock data environment
echo "[5/8] Launching app with mock data..."
xcrun simctl launch --console --terminate-running-process "$SIMULATOR_ID" com.donnadony.CryptoPortfolio \
    --ui_testing \
    --mock_data_enabled &
APP_PID=$!
sleep 5

echo "[6/8] Capturing screenshots..."

# Function to capture screenshot
capture_screenshot() {
    local filename=$1
    local output_path="$2"
    echo "  Capturing: $filename"
    xcrun simctl io "$SIMULATOR_ID" screenshot --type=png "$output_path/$filename.png"
    sleep 1
}

# ============================================
# LIGHT MODE SCREENSHOTS
# ============================================
echo ""
echo "--- LIGHT MODE SCREENSHOTS ---"

# Ensure light mode
xcrun simctl ui "$SIMULATOR_ID" appearance light
sleep 2

# 1. Portfolio Tab
echo "  [Tab 1/5] Portfolio (Light)"
capture_screenshot "01_portfolio" "$SCREENSHOTS_DIR/light"

# 2. Market Tab
echo "  Tapping Market tab..."
xcrun simctl spawn "$SIMULATOR_ID" launchctl submit -l tap.market -- /usr/bin/osascript -e '
tell application "System Events"
    tell process "CryptoPortfolio"
        click button "Market" of tab bar 1 of window 1
    end tell
end tell' 2>/dev/null || true

# Use UI test to navigate instead
xcodebuild test-without-building \
    -xctestrun "$BUILD_DIR/Build/Products/CryptoPortfolio_iphonesimulator26.2-x86_64.xctestrun" \
    -only-testing:CryptoPortfolioUITests/CryptoPortfolioUITests/testNavigateAllTabs \
    -destination "platform=iOS Simulator,id=$SIMULATOR_ID" 2>&1 | tail -5 || true

sleep 2
echo "  [Tab 2/5] Market (Light)"
capture_screenshot "02_market" "$SCREENSHOTS_DIR/light"

echo "========================================="
echo "Screenshots captured!"
echo "========================================="
echo "Location: $SCREENSHOTS_DIR"
ls -la "$SCREENSHOTS_DIR/light/"

# Shutdown simulator
xcrun simctl shutdown "$SIMULATOR_ID" 2>/dev/null || true
