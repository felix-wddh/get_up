# Manual QA Checklist - GetUp v1

## 1. App Icon Verification
- [ ] **Home Screen**: Icon (Blue Arrow) is clearly visible.
- [ ] **No Double Corners**: The icon does not have a rounded border inside the iOS rounded mask.
- [ ] **Sizing**: Icon fills the mask appropriately (not too small, not cropped).
- [ ] **Consistency**: Check Spotlight, Settings, and App Switcher for consistent rendering.

## 2. Onboarding Flow (E2E)
- [ ] **Connection (Step 1)**:
    - [ ] Tapping "Link your GetUp" triggers NFC scan.
    - [ ] Successful scan shows "Tag successfully linked!" and auto-advances.
    - [ ] Cancelled scan allows retry via the Blue CTA.
- [ ] **Configuration (Step 2)**:
    - [ ] Time picker works correctly.
    - [ ] Tapping "Set Alarm Time" advances to Placement.
- [ ] **Placement (Step 3)**:
    - [ ] Instructions readable.
    - [ ] "Next" button advances to Verification.
- [ ] **Verification (Step 4)**:
    - [ ] Final "Test and Start" screen shown.
    - [ ] Tapping "Start Getting Up" dismisses onboarding.

## 3. UI & Typography
- [ ] **Onboarding Logo**: Image B is shown on a white card background with professional rounding.
- [ ] **Scan View**: Narrower, centered layout (max width 300 for text).
- [ ] **Dynamic Type**: Increase system font size; ensure layouts don't break.
- [ ] **CTA Button**: Premium Blue (#007AFF) box with Image A is centered and avoids "white square" edges via masking.

## 4. NFC Functionality
- [ ] **Physical Device**: Verify NFC session starts and stops correctly.
- [ ] **Simulated**: Verify fallback or debug mock scan works in `NFCScanView`.
