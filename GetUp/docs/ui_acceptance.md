# UI Acceptance Checklist - GetUp v1 Onboarding

## Pre-Testing Setup
- [ ] Reset onboarding state: `defaults write de.felix.getup hasCompletedOnboarding -bool false`
- [ ] Build app in Debug configuration
- [ ] Test on iOS 26.2+ simulator or device

---

## Step 0: Front Page (Welcome Screen)

### Visual Verification
- [ ] GetUp logo (blue arrow + dot) is visible and centered
- [ ] Cyan glow effect surrounds the logo
- [ ] "Congrats 🎉" text is fully visible
- [ ] "You will get more out of your life now!" text is fully visible
- [ ] "Let's Go →" button is visible at bottom
- [ ] No UI elements overlap or occlude each other
- [ ] No "giant blue rectangle" blocking the hero area

### Interaction
- [ ] "Let's Go" button is tappable
- [ ] Tapping navigates to Step 1 (Connection)
- [ ] Animation is smooth

---

## Step 1: Connection Page

### Visual Verification
- [ ] Progress indicator shows 1 of 4 capsules filled
- [ ] "Connection" title is visible
- [ ] Subtitle text is visible
- [ ] Blue "Link your GetUp" CTA button is properly sized (button-sized, not card-sized)
- [ ] CTA button has white NFC icon, text, and chevron
- [ ] CTA button does NOT overlap other content
- [ ] CTA button is below the title/subtitle

### Interaction
- [ ] CTA button is tappable
- [ ] NFC scan initiates (or shows "NFC requires physical device" on simulator)
- [ ] After successful scan, success card appears
- [ ] Auto-navigates to Step 2 after ~1.2 seconds

---

## Step 2: Configuration Page

### Visual Verification
- [ ] Progress indicator shows 2 of 4 capsules filled
- [ ] "Configuration" title is visible
- [ ] Date picker (time wheel) is visible
- [ ] "Set Alarm Time" button is visible

### Interaction
- [ ] Time picker is scrollable
- [ ] "Set Alarm Time" navigates to Step 3

---

## Step 3: Placement Page

### Visual Verification
- [ ] Progress indicator shows 3 of 4 capsules filled
- [ ] "Placement" title is visible
- [ ] Instructions about tag placement are visible
- [ ] Guidance card with 3 steps is visible
- [ ] "Next" navigation button is visible

### Interaction
- [ ] "Next" button navigates to Step 4

---

## Step 4: Verification Page

### Visual Verification
- [ ] Progress indicator shows 4 of 4 capsules filled
- [ ] "Verification" title is visible
- [ ] Checkmark icon with glow is visible
- [ ] "Start Getting Up" button is visible

### Interaction
- [ ] "Start Getting Up" completes onboarding
- [ ] App transitions to main Alarms tab

---

## Device Size Testing

### iPhone SE (Small - 375pt width)
- [ ] All content fits without horizontal scrolling
- [ ] Text is not truncated unexpectedly
- [ ] Buttons are tappable (minimum 44pt touch targets)
- [ ] Logo is appropriately sized

### iPhone 15 (Medium - 393pt width)
- [ ] Layout looks balanced
- [ ] Proper vertical spacing between elements

### iPhone 15 Pro Max (Large - 430pt width)
- [ ] Content doesn't look too small/sparse
- [ ] Layout scales appropriately

---

## NFC-Specific Notes

| Environment | Expected Behavior |
|------------|-------------------|
| Simulator | NFC unavailable message; "Mock NFC Scan" button in DEBUG |
| Device (unsigned) | May show NFC capability error |
| Device (signed w/ entitlement) | Full NFC scanning works |

---

## Pass/Fail Summary

| Test Area | Status |
|-----------|--------|
| Step 0 Layout | |
| Step 1 Layout | |
| Step 2 Layout | |
| Step 3 Layout | |
| Step 4 Layout | |
| Navigation Flow | |
| iPhone SE | |
| iPhone 15 | |
| iPhone 15 Pro Max | |

**Tester:** _______________
**Date:** _______________
**Build:** _______________
**Result:** [ ] PASS / [ ] FAIL
