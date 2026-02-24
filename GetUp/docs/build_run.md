# Build and Run Guide for GetUp (v1)

This document provides instructions for ensuring a consistent and successful build of the GetUp iOS application.

## Prerequisites
- **Xcode**: Version 15.0 or later (Tested on 16.x and latest 26.2 simulators).
- **iOS Target**: iOS 26.2 (Deployment Target).

## Configuration Verification
To resolve "Application failed preflight checks" or SBMainWorkspace errors:
1.  **Deployment Target**: Ensure `IPHONEOS_DEPLOYMENT_TARGET` is set to `26.2` for all targets.
2.  **Info.plist**: Ensure no manual `MinimumOSVersion` exists; let Xcode sync it automatically.
3.  **Automatic Generation**: `GENERATE_INFOPLIST_FILE` is set to `NO` to enforce the manual manifest at `GetUp/Info.plist`.

## Troubleshooting Simulator Launch
If the simulator remains "Busy" or fails preflight:
1.  **Clean**: `Product` > `Clean Build Folder` (`Shift + CMD + K`).
2.  **Reset Simulator**: In the Simulator menu, go to `Device` > `Erase All Content and Settings...`.
3.  **Delete DerivedData**: `rm -rf ~/Library/Developer/Xcode/DerivedData/GetUp-*`
4.  **Rebuild**: Press Play in Xcode.

## Branding & Visuals
All branding (App Logo) is now 100% vector-based SwiftUI `Shapes`. No external images are required for the in-app hero visuals, ensuring perfect rendering on any deployment target version.
