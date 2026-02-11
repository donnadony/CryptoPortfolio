#!/bin/bash
# Screenshot capture using xcrun simctl during XCUITest execution

set -e

PROJECT_DIR="/Users/donnadony/Documents/personal/CryptoPortfolio"
BUILD_DIR="$PROJECT_DIR/build"
SCREENSHOTS_DIR="$PROJECT_DIR/fastlane/screenshots"
SIMULATOR_ID="E7F05F76-2332-4118-BD0D-3095E5D7C302"

echo "========================================="
echo "CryptoPortfolio Screenshot Capture"
echo "========================================="

# Create directories
mkdir -p "$SCREENSHOTS_DIR/light"
mkdir -p "$SCREENSHOTS_DIR/dark"

# Shutdown any existing
echo "[1/5] Preparing simulator..."
xcrun simctl shutdown "$SIMULATOR_ID" 2>/dev/null || true
sleep 2
xcrun simctl boot "$SIMULATOR_ID"
sleep 5

# Wait for boot
echo "[2/5] Waiting for simulator..."
until xcrun simctl list devices | grep "$SIMULATOR_ID" | grep -q "Booted"; do
    sleep 1
done
echo "Simulator ready!"

# Install app
echo "[3/5] Installing app..."
xcrun simctl install "$SIMULATOR_ID" "$BUILD_DIR/Build/Products/Debug-iphonesimulator/CryptoPortfolio.app"

# Launch in light mode first
echo "[4/5] Setting light mode..."
xcrun simctl ui "$SIMULATOR_ID" appearance light
sleep 2

# Launch app
echo "[5/5] Launching app..."
xcrun simctl launch --console "$SIMULATOR_ID" com.donnadony.CryptoPortfolio &
echo $! > /tmp/app.pid
sleep 5

# Capture screenshots manually using simctl
echo ""
echo "--- Capturing Screenshots ---"

# Portfolio (Light)
echo "  Capturing 01_portfolio_light..."
xcrun simctl io "$SIMULATOR_ID" screenshot --type=png "$SCREENSHOTS_DIR/light/01_portfolio.png"
sleep 2

# Shutdown
echo ""
echo "Shutting down..."
xcrun simctl shutdown "$SIMULATOR_ID" 2>/dev/null || true

echo ""
echo "Done! Screenshots saved to:"
echo "  $SCREENSHOTS_DIR/light/"
echo "  $SCREENSHOTS_DIR/dark/"
ls -la "$SCREENSHOTS_DIR/light/" 2>/dev/null || echo "  No light screenshots yet"
ls -la "$SCREENSHOTS_DIR/dark/" 2>/dev/null || echo "  No dark screenshots yet"
