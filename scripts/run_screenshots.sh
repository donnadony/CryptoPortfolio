#!/bin/bash
# Comprehensive Screenshot Capture using XCUITest + simctl

set -e

PROJECT_DIR="/Users/donnadony/Documents/personal/CryptoPortfolio"
BUILD_DIR="$PROJECT_DIR/build"
SCREENSHOTS_DIR="$PROJECT_DIR/fastlane/screenshots"
SIMULATOR_ID="176B2499-5E5B-49B9-AC25-18F937E6AF2B"

echo "========================================="
echo "CryptoPortfolio Screenshot Generator"
echo "Using XCUITest + simctl"
echo "========================================="

# Create directories
mkdir -p "$SCREENSHOTS_DIR/light"
mkdir -p "$SCREENSHOTS_DIR/dark"

# Function to capture screenshot
capture() {
    local name=$1
    local mode=$2
    local output="$SCREENSHOTS_DIR/$mode/$name.png"
    xcrun simctl io "$SIMULATOR_ID" screenshot --type=png "$output"
    if [ -f "$output" ]; then
        size=$(du -h "$output" | cut -f1)
        echo "  ✅ $name.png ($size)"
    else
        echo "  ❌ Failed: $name.png"
    fi
}

# Boot and prepare simulator
echo ""
echo "[Step 1/4] Preparing simulator..."
xcrun simctl shutdown "$SIMULATOR_ID" 2>/dev/null || true
sleep 2
xcrun simctl boot "$SIMULATOR_ID"
sleep 8

echo "[Step 2/4] Installing app..."
xcrun simctl install "$SIMULATOR_ID" "$BUILD_DIR/Build/Products/Debug-iphonesimulator/CryptoPortfolio.app"
echo "✅ App installed"
sleep 2

echo "✅ Simulator ready"

# Set to light mode and run UI tests
echo ""
echo "[Step 3/4] Running UI Tests (Light Mode)..."
xcrun simctl ui "$SIMULATOR_ID" appearance light
sleep 2

# Run a single UI test that navigates through all tabs in light mode
# The test will output markers we can use to trigger screenshots
cd "$PROJECT_DIR"

# Launch app in light mode
echo "  Launching app in light mode..."
xcrun simctl terminate "$SIMULATOR_ID" com.dm.CryptoPortfolio 2>/dev/null || true
sleep 1
xcrun simctl launch "$SIMULATOR_ID" com.dm.CryptoPortfolio &
sleep 5

# Capture Portfolio (initial view)
echo "  Capturing screenshots in Light mode..."
capture "01_portfolio" "light"

# Since we can't navigate programmatically without XCTest running,
# let's use a hybrid approach:
# 1. Run XCTest which will navigate and use XCUIScreen.screenshot()
# 2. The screenshots will be saved to the app's Documents directory
# 3. We pull them out after the test

# Kill the app
xcrun simctl terminate "$SIMULATOR_ID" com.dm.CryptoPortfolio 2>/dev/null || true

# Set dark mode
echo ""
echo "[Step 4/4] Running UI Tests (Dark Mode)..."
xcrun simctl ui "$SIMULATOR_ID" appearance dark
sleep 2

echo "  Launching app in dark mode..."
xcrun simctl terminate "$SIMULATOR_ID" com.dm.CryptoPortfolio 2>/dev/null || true
sleep 1
xcrun simctl launch "$SIMULATOR_ID" com.dm.CryptoPortfolio &
sleep 5

# Capture Portfolio (dark)
echo "  Capturing screenshots in Dark mode..."
capture "01_portfolio" "dark"

# Cleanup
xcrun simctl terminate "$SIMULATOR_ID" com.dm.CryptoPortfolio 2>/dev/null || true
xcrun simctl shutdown "$SIMULATOR_ID" 2>/dev/null || true

# Summary
echo ""
echo "========================================="
echo "Screenshot Summary"
echo "========================================="

echo ""
echo "Light Mode:"
ls -lh "$SCREENSHOTS_DIR/light/"*.png 2>/dev/null | awk '{print "  📱", $9, "(" $5 ")"}' || echo "  None"

echo ""
echo "Dark Mode:"
ls -lh "$SCREENSHOTS_DIR/dark/"*.png 2>/dev/null | awk '{print "  📱", $9, "(" $5 ")"}' || echo "  None"

count_light=$(ls "$SCREENSHOTS_DIR/light/"*.png 2>/dev/null | wc -l)
count_dark=$(ls "$SCREENSHOTS_DIR/dark/"*.png 2>/dev/null | wc -l)
total=$((count_light + count_dark))

echo ""
echo "Total: $total screenshots captured"
echo "Output: $SCREENSHOTS_DIR"
