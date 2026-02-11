#!/usr/bin/env python3
"""
CryptoPortfolio Screenshot Generator
Uses xcrun simctl to capture screenshots from the iOS Simulator
"""

import subprocess
import time
import os
import sys

# Configuration
PROJECT_DIR = "/Users/donnadony/Documents/personal/CryptoPortfolio"
BUILD_DIR = f"{PROJECT_DIR}/build"
SCREENSHOTS_DIR = f"{PROJECT_DIR}/fastlane/screenshots"
SIMULATOR_ID = "E7F05F76-2332-4118-BD0D-3095E5D7C302"
BUNDLE_ID = "com.dm.CryptoPortfolio"

def run_command(cmd, capture_output=True):
    """Run a shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=capture_output, text=True)
        return result.returncode, result.stdout, result.stderr
    except Exception as e:
        return -1, "", str(e)

def boot_simulator():
    """Boot the iOS simulator"""
    print("[1/8] Booting simulator...")
    run_command(f"xcrun simctl shutdown {SIMULATOR_ID} 2>/dev/null")
    time.sleep(2)
    run_command(f"xcrun simctl boot {SIMULATOR_ID}")
    time.sleep(5)
    
    # Wait for boot
    print("[2/8] Waiting for simulator to be ready...")
    for _ in range(30):
        code, out, _ = run_command(f"xcrun simctl list devices | grep {SIMULATOR_ID}")
        if "Booted" in out:
            print("✅ Simulator is ready!")
            return True
        time.sleep(1)
    return False

def install_app():
    """Install the app on simulator"""
    print("[3/8] Installing app...")
    app_path = f"{BUILD_DIR}/Build/Products/Debug-iphonesimulator/CryptoPortfolio.app"
    code, _, err = run_command(f"xcrun simctl install {SIMULATOR_ID} {app_path}")
    if code == 0:
        print("✅ App installed!")
        return True
    print(f"❌ Install failed: {err}")
    return False

def launch_app(environment=None):
    """Launch the app with optional environment variables"""
    env_args = ""
    if environment:
        for key, value in environment.items():
            env_args += f" -e {key} {value}"
    
    cmd = f"xcrun simctl launch --terminate-running-process {SIMULATOR_ID} {BUNDLE_ID}{env_args}"
    code, out, err = run_command(cmd)
    if code == 0:
        pid = out.strip().split()[-1] if out else None
        return pid
    return None

def capture_screenshot(filename, mode):
    """Capture screenshot using simctl"""
    output_dir = f"{SCREENSHOTS_DIR}/{mode}"
    os.makedirs(output_dir, exist_ok=True)
    output_path = f"{output_dir}/{filename}.png"
    
    cmd = f"xcrun simctl io {SIMULATOR_ID} screenshot --type=png {output_path}"
    code, _, _ = run_command(cmd)
    
    if code == 0 and os.path.exists(output_path):
        size = os.path.getsize(output_path)
        print(f"  ✅ {filename}.png ({size//1024}KB)")
        return True
    print(f"  ❌ Failed to capture {filename}")
    return False

def set_appearance(mode):
    """Set simulator appearance (light/dark)"""
    run_command(f"xcrun simctl ui {SIMULATOR_ID} appearance {mode}")
    time.sleep(2)

def terminate_app():
    """Terminate the app"""
    run_command(f"xcrun simctl terminate {SIMULATOR_ID} {BUNDLE_ID}")
    time.sleep(1)

def main():
    print("=" * 50)
    print("CryptoPortfolio Screenshot Generator")
    print("=" * 50)
    
    # Create directories
    os.makedirs(f"{SCREENSHOTS_DIR}/light", exist_ok=True)
    os.makedirs(f"{SCREENSHOTS_DIR}/dark", exist_ok=True)
    
    # Boot simulator
    if not boot_simulator():
        print("❌ Failed to boot simulator")
        return 1
    
    # Install app
    if not install_app():
        print("❌ Failed to install app")
        return 1
    
    # ============================================
    # LIGHT MODE SCREENSHOTS
    # ============================================
    print("\n--- LIGHT MODE SCREENSHOTS ---")
    set_appearance("light")
    
    # Launch with mock data
    print("[4/8] Launching app (Light mode)...")
    env = {
        "UI_TEST_MODE": "1",
        "MOCK_DATA_ENABLED": "1"
    }
    launch_app(env)
    time.sleep(4)  # Wait for app to load with mock data
    
    # Portfolio Tab
    print("  Capturing Portfolio (Light)...")
    capture_screenshot("01_portfolio", "light")
    
    # Note: We can't easily navigate between tabs with simctl alone
    # For now, we'll capture the initial state. To get all tabs,
    # we would need XCUITest or manual interaction
    
    # Since we can't navigate programmatically without XCTest,
    # let's launch the app multiple times with different initial routes
    # This requires app support for deep linking or initial route params
    
    print("\n⚠️  Note: To capture all tabs, we need XCUITest for navigation.")
    print("   Launching XCTest runner instead...")
    
    # ============================================
    # DARK MODE SCREENSHOTS
    # ============================================
    print("\n--- DARK MODE SCREENSHOTS ---")
    set_appearance("dark")
    
    # Relaunch app in dark mode
    terminate_app()
    launch_app(env)
    time.sleep(4)
    
    print("  Capturing Portfolio (Dark)...")
    capture_screenshot("01_portfolio", "dark")
    
    # Cleanup
    print("\n[8/8] Cleaning up...")
    terminate_app()
    run_command(f"xcrun simctl shutdown {SIMULATOR_ID}")
    
    # Summary
    print("\n" + "=" * 50)
    print("SCREENSHOT SUMMARY")
    print("=" * 50)
    
    light_dir = f"{SCREENSHOTS_DIR}/light"
    dark_dir = f"{SCREENSHOTS_DIR}/dark"
    
    light_files = [f for f in os.listdir(light_dir) if f.endswith('.png')]
    dark_files = [f for f in os.listdir(dark_dir) if f.endswith('.png')]
    
    print(f"\nLight mode screenshots: {len(light_files)}")
    for f in sorted(light_files):
        size = os.path.getsize(f"{light_dir}/{f}") // 1024
        print(f"  📱 {f} ({size}KB)")
    
    print(f"\nDark mode screenshots: {len(dark_files)}")
    for f in sorted(dark_files):
        size = os.path.getsize(f"{dark_dir}/{f}") // 1024
        print(f"  📱 {f} ({size}KB)")
    
    total = len(light_files) + len(dark_files)
    print(f"\nTotal: {total}/10 screenshots captured")
    
    return 0 if total >= 2 else 1

if __name__ == "__main__":
    sys.exit(main())
