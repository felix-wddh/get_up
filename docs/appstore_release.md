# App Store Release Pack - GetUp v1

## Reviewer Instructions
1. Launch the app for the first time.
2. Follow the 4-step onboarding flow.
3. On the **Connection** step, tap "Link your GetUp" and scan an NFC tag (requires physical device) or observe the system dialog.
4. Set an alarm time in **Configuration**.
5. Read **Placement** instructions.
6. Complete **Verification** to enter the main app.
7. To test alarm dismissal: Create an alarm, wait for it to fire, and use the registered tag to stop it.

## Permissions & Entitlements
- **NFC (Near Field Communication)**: Used to verify that the user has physically moved to their GetUp tag location to stop the alarm. Essential for the app's core value proposition.
- **Notifications**: Used to fire the alarm even when the app is in the background.

## Privacy Statement
- **Data Stored**: 
    - A cryptographic hash (SHA-256) of the NFC tag identifier.
    - Alarm times and settings.
- **Location**: All data is stored locally on the device via SwiftData and UserDefaults.
- **Privacy**: No personal data or raw NFC identifiers are transmitted to any server.

## Known Limitations
- NFC scanning requires a physical device; it cannot be fully tested on Simulator.
- Emergency bypass is available via a 20-second continuous hold, as per safety guidelines.
