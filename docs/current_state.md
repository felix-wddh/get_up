# Current State Summary - GetUp

## Current Onboarding Flow
The current onboarding is structured in 4 steps within `OnboardingView.swift`:
1. **Front Page (Step 0)**: "Let's Go" welcome screen.
2. **Step 1: Placement**: Instructs user to place tag 3m away before linking it.
3. **Step 2: Link Tag**: User taps "Link Tag" button to perform NFC scan.
4. **Step 3: GetUp Mode**: Toggle to enable/disable the mode.

### Step 2 Confusion
The confusion arises because **Placement** is instructed *before* the **Connection**. Users are told where to put the tag before they even know if it works or have it linked. The new flow correctly prioritizes the connection first, followed by configuration, and only then placement instructions once the technical bond is established.

## File/Module Map for Changes
- **`GetUp/GetUp/DesignSystem.swift`**: Update typography to support Dynamic Type and unify heading/bullet styles. Ensure official logo usage avoids "double corners".
- **`GetUp/GetUp/Screens/OnboardingView.swift`**: Complete rewrite to match the new 4-step flow: Connection → Configuration → Placement → Verification.
- **`GetUp/GetUp/Screens/NFCScanView.swift`**: Refactor visual layout to be narrower and centered.
- **`GetUp/GetUp/Assets.xcassets`**:
    - Update `AppIcon` with Image B (formatted correctly).
    - Add Image A as `NFCContactlessIcon` for the CTA box.
- **`GetUp/GetUp/Components.swift`**: Add the new Blue CTA box component.

## Technical Stack
- **UI Framework**: SwiftUI (liquid glass aesthetic).
- **Persistence**: SwiftData (`AlarmEntity`).
- **NFC Implementation**: `NFCService.swift` wrapping `CoreNFC`.
- **Alarm Scheduling**: `AlarmService.swift` using `AlarmKit`.
- **Minimum iOS**: Not explicitly stated but uses `symbolEffect` and `SwiftData`, implying iOS 17+.
