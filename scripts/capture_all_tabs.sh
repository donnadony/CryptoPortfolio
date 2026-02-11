#!/bin/bash
# Complete Screenshot Capture - All 5 tabs in Light and Dark modes

set -e

PROJECT_DIR="/Users/donnadony/Documents/personal/CryptoPortfolio"
BUILD_DIR="$PROJECT_DIR/build"
SCREENSHOTS_DIR="$PROJECT_DIR/fastlane/screenshots"
SIMULATOR_ID="176B2499-5E5B-49B9-AC25-18F937E6AF2B"

echo "========================================="
echo "CryptoPortfolio - Full Screenshot Suite"
echo "========================================="

# Create directories
mkdir -p "$SCREENSHOTS_DIR/light"
mkdir -p "$SCREENSHOTS_DIR/dark"

# Function to capture screenshot
capture() {
    local name=$1
    local mode=$2
    local output="$SCREENSHOTS_DIR/$mode/$name.png"
    xcrun simctl io "$SIMULATOR_ID" screenshot --type=png "$output" 2>/dev/null
    if [ -f "$output" ]; then
        size=$(du -h "$output" | cut -f1)
        echo "  ✅ $name.png ($size)"
    else
        echo "  ❌ Failed: $name.png"
    fi
}

# Function to tap on a tab using simctl send event
tap_tab() {
    local tab_name=$1
    # Coordinates for iPhone 17 Pro tab bar (approximate)
    # Tab bar is at bottom: Portfolio ~80, Market ~160, Analytics ~240, Watchlist ~320, Settings ~400
    case $tab_name in
        "Portfolio") x=80; y=840;;
        "Market") x=160; y=840;;
        "Analytics") x=240; y=840;;
        "Watchlist") x=320; y=840;;
        "Settings") x=400; y=840;;
        *) x=80; y=840;;
    esac
    xcrun simctl touch "$SIMULATOR_ID" $x $y 2>/dev/null || true
    sleep 1.5
}

# Boot simulator
echo ""
echo "[1/6] Booting simulator..."
xcrun simctl shutdown "$SIMULATOR_ID" 2>/dev/null || true
sleep 2
xcrun simctl boot "$SIMULATOR_ID"
sleep 8

# Install app
echo "[2/6] Installing app..."
xcrun simctl install "$SIMULATOR_ID" "$BUILD_DIR/Build/Products/Debug-iphonesimulator/CryptoPortfolio.app"
echo "✅ App installed"

# ============================================
# LIGHT MODE SCREENSHOTS
# ============================================
echo ""
echo "[3/6] Capturing Light Mode screenshots..."
xcrun simctl ui "$SIMULATOR_ID" appearance light
sleep 2

# Launch app
echo "  Launching app..."
xcrun simctl terminate "$SIMULATOR_ID" com.dm.CryptoPortfolio 2>/dev/null || true
sleep 1
xcrun simctl launch "$SIMULATOR_ID" com.dm.CryptoPortfolio &
sleep 5

# Portfolio (default tab)
echo "  📸 Tab 1/5: Portfolio (Light)"
capture "01_portfolio" "light"

# Market
echo "  📸 Tab 2/5: Market (Light)"
tap_tab "Market"
capture "02_market" "light"

# Analytics
echo "  📸 Tab 3/5: Analytics (Light)"
tap_tab "Analytics"
capture "03_analytics" "light"

# Watchlist
echo "  📸 Tab 4/5: Watchlist (Light)"
tap_tab "Watchlist"
capture "04_watchlist" "light"

# Settings
echo "  📸 Tab 5/5: Settings (Light)"
tap_tab "Settings"
capture "05_settings" "light"

# ============================================
# DARK MODE SCREENSHOTS
# ============================================
echo ""
echo "[4/6] Capturing Dark Mode screenshots..."
xcrun simctl ui "$SIMULATOR_ID" appearance dark
sleep 3

# Relaunch app to pick up dark mode
echo "  Relaunching app for dark mode..."
xcrun simctl terminate "$SIMULATOR_ID" com.dm.CryptoPortfolio 2>/dev/null || true
sleep 1
xcrun simctl launch "$SIMULATOR_ID" com.dm.CryptoPortfolio &
sleep 5

# Portfolio (default tab)
echo "  📸 Tab 1/5: Portfolio (Dark)"
capture "01_portfolio" "dark"

# Market
echo "  📸 Tab 2/5: Market (Dark)"
tap_tab "Market"
capture "02_market" "dark"

# Analytics
echo "  📸 Tab 3/5: Analytics (Dark)"
tap_tab "Analytics"
capture "03_analytics" "dark"

# Watchlist
echo "  📸 Tab 4/5: Watchlist (Dark)"
tap_tab "Watchlist"
capture "04_watchlist" "dark"

# Settings
echo "  📸 Tab 5/5: Settings (Dark)"
tap_tab "Settings"
capture "05_settings" "dark"

# Cleanup
echo ""
echo "[5/6] Cleaning up..."
xcrun simctl terminate "$SIMULATOR_ID" com.dm.CryptoPortfolio 2>/dev/null || true
xcrun simctl shutdown "$SIMULATOR_ID" 2>/dev/null || true

# ============================================
# SUMMARY
# ============================================
echo ""
echo "========================================="
echo "📊 Screenshot Summary"
echo "========================================="

echo ""
echo "📁 Light Mode:"
for f in "$SCREENSHOTS_DIR/light"/0*.png 2>/dev/null | sort; do
    if [ -f "$f" ]; then
        name=$(basename "$f")
        size=$(du -h "$f" | cut -f1)
        echo "    ✅ $name ($size)"
    fi
done

echo ""
echo "📁 Dark Mode:"
for f in "$SCREENSHOTS_DIR/dark"/0*.png 2>/dev/null | sort; do
    if [ -f "$f" ]; then
        name=$(basename "$f")
        size=$(du -h "$f" | cut -f1)
        echo "    ✅ $name ($size)"
    fi
done

count_light=$(ls "$SCREENSHOTS_DIR/light/"0*.png 2>/dev/null | wc -l | tr -d ' ')
count_dark=$(ls "$SCREENSHOTS_DIR/dark/"0*.png 2>/dev/null | wc -l | tr -d ' ')
total=$((count_light + count_dark))

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Total: $total/10 screenshots captured"
echo "  Location: $SCREENSHOTS_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $total -eq 10 ]; then
    echo ""
    echo "🎉 All screenshots captured successfully!"
    exit 0
else
    echo ""
    echo "⚠️  Some screenshots may be missing"
    exit 1
fi
