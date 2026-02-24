# UI Root Cause Analysis: Onboarding Layout Bug

## Issue
The first onboarding screen displays a "giant blue rounded rectangle" that occludes the hero/logo area.

## Root Cause

**Confirmed via runtime testing:** Two issues were identified:

### Issue 1: TabView Page Bleed
The `LinkCTAButton` component from **step 1** was being pre-rendered and visible on **step 0** due to TabView page pre-rendering behavior.

### Issue 2: AppLogo Shape Misalignment (Primary Cause)
The `AppLogo` vector shape coordinates were not centered within their 500x500 coordinate space:
- Arrow shape: x range 150-340, y range 180-330 (biased to right)
- Dot shape: centered at (265, 170) (biased to right)

This caused the AppLogo to render predominantly on the right side of its frame, creating the appearance of a "giant blue rectangle" expanding beyond the hero area.

### Issue 3: Missing Layout Constraints
The hero ZStack had `.frame(maxWidth: .infinity)` without explicit height constraint, and the VStack lacked proper spacing consideration for the navigation button overlay.

## Fixes Applied

### 1. TabView Page Clipping
Added `.frame(maxWidth: .infinity, maxHeight: .infinity)` and `.clipped()` to each TabView page to prevent content overflow.

### 2. AppLogo Rewrite
Completely rewrote the AppLogo vector shapes to match the official app icon:
- Arrow shape: Dynamic upward-sweeping curve from bottom-left to upper-right
- Dot shape: "Head" circle positioned above the arrow tip
- Added `.clipped()` to prevent overflow
- Used relative coordinates (percentages of frame) for proper scaling

**File**: `Screens/AppLogo.swift`

### 3. Layout Constraints
- Changed hero layout to use AppLogo with GlowCircle as `.background()` instead of ZStack
- Added `.fixedSize(horizontal: false, vertical: true)` to text for proper multiline rendering
- Added extra Spacer() to push content above the navigation button

**File**: `Screens/OnboardingView.swift`

## Verification

Tested on 3 device sizes:
- iPhone 16e (small): Layout fits correctly
- iPhone 17 (medium): Layout balanced
- iPhone 17 Pro Max (large): Layout scales appropriately

All content visible:
- GetUp logo centered with cyan glow
- "Congrats 🎉 You will get more out of your life now!" fully readable
- "Let's Go" button properly positioned
