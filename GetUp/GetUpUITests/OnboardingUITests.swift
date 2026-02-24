import XCTest

/// UI Tests for GetUp Onboarding Flow
/// Note: Add this file to a UI Test target in Xcode to run these tests
final class OnboardingUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false

        // Reset onboarding state for testing
        app.launchArguments = ["--reset-onboarding"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Step 0: Front Page Tests

    func testFrontPageElementsVisible() throws {
        // Verify the congratulations text is visible
        let congratsText = app.staticTexts["Congrats 🎉"]
        XCTAssertTrue(congratsText.waitForExistence(timeout: 5), "Front page should show congrats message")

        // Verify the full message text is visible
        let messageText = app.staticTexts["You will get more"]
        XCTAssertTrue(messageText.exists || app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'life now'")).firstMatch.exists,
                      "Full motivational message should be visible")

        // Verify Let's Go button exists and is tappable
        let letsGoButton = app.buttons["Let's Go"]
        XCTAssertTrue(letsGoButton.exists, "Let's Go button should exist on step 0")
        XCTAssertTrue(letsGoButton.isHittable, "Let's Go button should be tappable")
    }

    func testFrontPageLayoutNotObscured() throws {
        // The congratulations text should be visible (not covered by other elements)
        let congratsText = app.staticTexts["Congrats 🎉"]
        XCTAssertTrue(congratsText.waitForExistence(timeout: 5))
        XCTAssertTrue(congratsText.isHittable, "Congrats text should be visible, not obscured")

        // Navigation button should be at bottom, not overlapping content
        let letsGoButton = app.buttons["Let's Go"]
        XCTAssertTrue(letsGoButton.exists)
        XCTAssertTrue(letsGoButton.isHittable, "Navigation button should be visible")

        // Button should be below the text
        if congratsText.exists && letsGoButton.exists {
            XCTAssertTrue(letsGoButton.frame.minY > congratsText.frame.maxY,
                          "Navigation button should be positioned below the congratulations text")
        }
    }

    // MARK: - Navigation Tests

    func testNavigateToConnectionStep() throws {
        // Start on step 0
        let letsGoButton = app.buttons["Let's Go"]
        XCTAssertTrue(letsGoButton.waitForExistence(timeout: 5), "Let's Go button should exist")

        // Tap to navigate to step 1
        letsGoButton.tap()

        // Verify step 1 (Connection) appears
        let connectionTitle = app.staticTexts["Connection"]
        XCTAssertTrue(connectionTitle.waitForExistence(timeout: 3), "Connection step should appear after tapping Let's Go")

        // Verify LinkCTAButton exists
        let linkButton = app.buttons["Link your GetUp"]
        XCTAssertTrue(linkButton.waitForExistence(timeout: 2), "Link CTA button should exist on connection step")
    }

    func testConnectionStepLayout() throws {
        // Navigate to step 1
        let letsGoButton = app.buttons["Let's Go"]
        XCTAssertTrue(letsGoButton.waitForExistence(timeout: 5))
        letsGoButton.tap()

        // Wait for connection step
        let connectionTitle = app.staticTexts["Connection"]
        XCTAssertTrue(connectionTitle.waitForExistence(timeout: 3))

        // Verify the link button is properly positioned (below title)
        let linkButton = app.buttons["Link your GetUp"]
        XCTAssertTrue(linkButton.waitForExistence(timeout: 2))

        if connectionTitle.exists && linkButton.exists {
            XCTAssertTrue(linkButton.frame.minY > connectionTitle.frame.maxY,
                          "Link button should be positioned below the Connection title")
        }

        // Verify progress indicator is visible (step 1 shows progress)
        // Progress capsules should be visible at top
    }

    // MARK: - Accessibility Tests

    func testAccessibilityLabels() throws {
        // Verify buttons have proper accessibility
        let letsGoButton = app.buttons["Let's Go"]
        XCTAssertTrue(letsGoButton.waitForExistence(timeout: 5))
        XCTAssertFalse(letsGoButton.label.isEmpty, "Button should have accessibility label")
    }
}
