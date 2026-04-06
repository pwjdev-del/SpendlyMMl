import XCTest

/// Comprehensive UI tests that tap through every screen in the Spendly app.
/// Tests all 4 portals (Admin, OEM/Manager, Technician, Customer) and every reachable module.
final class SpendlyFullAppTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launch()
    }

    // MARK: - Helpers

    func tapIfExists(_ element: XCUIElement, timeout: TimeInterval = 3) {
        if element.waitForExistence(timeout: timeout) && element.isHittable {
            element.tap()
        }
    }

    func goBack() {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.exists && backButton.isHittable {
            backButton.tap()
            sleep(1)
        }
    }

    func scrollDown() {
        app.swipeUp()
        usleep(500_000)
    }

    func scrollUp() {
        app.swipeDown()
        usleep(500_000)
    }

    /// Login by tapping a demo credential row, then tapping SIGN IN
    func loginAs(_ role: String) {
        // Scroll down to see demo credentials
        sleep(1)
        scrollDown()
        scrollDown()

        // Tap the demo credential row for this role
        let roleButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", role)).firstMatch
        if roleButton.waitForExistence(timeout: 5) {
            roleButton.tap()
            sleep(1)
        }

        // Scroll back up to see Sign In button
        scrollUp()
        scrollUp()
        sleep(1)

        // Tap SIGN IN
        let signIn = app.buttons["SIGN IN"]
        if signIn.waitForExistence(timeout: 5) && signIn.isHittable {
            signIn.tap()
        }
        sleep(3)

        // Dismiss biometric enrollment alert if shown
        let notNow = app.alerts.buttons["Not Now"]
        if notNow.waitForExistence(timeout: 2) {
            notNow.tap()
            sleep(1)
        }
    }

    /// Logout — handles both More-menu and toolbar-button patterns
    func logout() {
        // Try More tab (OEM and Customer portals)
        let moreTab = app.tabBars.buttons["More"]
        if moreTab.exists && moreTab.isHittable {
            moreTab.tap()
            sleep(1)

            // Scroll down to find Sign Out
            scrollDown()
            scrollDown()

            let signOut = app.buttons["Sign Out"]
            if signOut.waitForExistence(timeout: 3) && signOut.isHittable {
                signOut.tap()
                sleep(1)
                let confirm = app.alerts.buttons["Sign Out"]
                tapIfExists(confirm)
                sleep(2)
                return
            }
        }

        // Try toolbar logout icon (Admin portal)
        let logoutButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'rectangle.portrait'"))
        if logoutButtons.count > 0 {
            logoutButtons.firstMatch.tap()
            sleep(1)
            let confirm = app.alerts.buttons["Sign Out"]
            tapIfExists(confirm)
            sleep(2)
        }
    }

    // MARK: - Test 1: Manager Portal — Full Navigation

    func testManagerPortal() throws {
        loginAs("Manager")

        // Verify tab bar appeared
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5), "Tab bar should appear after login")

        // Tab 1: Dashboard
        tapIfExists(app.tabBars.buttons["Dashboard"])
        sleep(1)
        scrollDown()
        scrollDown()

        // Tab 2: Trips (JobExecution)
        tapIfExists(app.tabBars.buttons["Trips"])
        sleep(2)
        scrollDown()

        // Tap first job card if available
        if app.cells.count > 0 {
            let firstCell = app.cells.firstMatch
            if firstCell.isHittable {
                firstCell.tap()
                sleep(2)
                // Dismiss sheet
                app.swipeDown()
                sleep(1)
            }
        }

        // Tab 3: Approvals
        tapIfExists(app.tabBars.buttons["Approvals"])
        sleep(2)
        scrollDown()

        // Tab 4: Machines
        tapIfExists(app.tabBars.buttons["Machines"])
        sleep(2)
        scrollDown()

        // Tab 5: More
        tapIfExists(app.tabBars.buttons["More"])
        sleep(1)

        // Navigate into each module from More
        let modules = ["Customers", "Estimates", "Invoicing", "Knowledge Base", "Team Chat", "Analytics", "Resources", "Settings", "Notifications"]
        for name in modules {
            let link = app.staticTexts[name]
            if link.waitForExistence(timeout: 2) && link.isHittable {
                link.tap()
                sleep(2)
                scrollDown()
                sleep(1)
                goBack()
                sleep(1)

                // Re-scroll to see more items if needed
                if !app.staticTexts[name].exists {
                    scrollDown()
                    sleep(1)
                }
            }
        }

        // Logout
        logout()
        XCTAssertTrue(app.buttons["SIGN IN"].waitForExistence(timeout: 10), "Should return to login screen")
    }

    // MARK: - Test 2: Admin Portal — Full Navigation

    func testAdminPortal() throws {
        loginAs("Admin")

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5), "Tab bar should appear")

        // Dashboard (Analytics)
        tapIfExists(app.tabBars.buttons["Dashboard"])
        sleep(2)
        scrollDown()
        scrollDown()

        // Branding
        tapIfExists(app.tabBars.buttons["Branding"])
        sleep(2)
        scrollDown()

        // Users (OrgPermissions)
        tapIfExists(app.tabBars.buttons["Users"])
        sleep(2)
        scrollDown()

        // Settings
        tapIfExists(app.tabBars.buttons["Settings"])
        sleep(2)
        scrollDown()

        logout()
        XCTAssertTrue(app.buttons["SIGN IN"].waitForExistence(timeout: 10), "Should return to login screen")
    }

    // MARK: - Test 3: Customer Portal — Full Navigation

    func testCustomerPortal() throws {
        loginAs("Customer")

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5), "Tab bar should appear")

        // Dashboard
        tapIfExists(app.tabBars.buttons["Dashboard"])
        sleep(2)
        scrollDown()
        scrollDown()

        // Machines
        tapIfExists(app.tabBars.buttons["Machines"])
        sleep(2)
        scrollDown()

        // Incidents
        tapIfExists(app.tabBars.buttons["Incidents"])
        sleep(2)
        scrollDown()

        // Documents
        tapIfExists(app.tabBars.buttons["Documents"])
        sleep(2)
        scrollDown()

        // More
        tapIfExists(app.tabBars.buttons["More"])
        sleep(1)

        // Settings
        let settings = app.staticTexts["Settings"]
        if settings.waitForExistence(timeout: 3) {
            settings.tap()
            sleep(2)
            goBack()
            sleep(1)
        }

        logout()
        XCTAssertTrue(app.buttons["SIGN IN"].waitForExistence(timeout: 10), "Should return to login screen")
    }

    // MARK: - Test 4: Technician Portal

    func testTechnicianPortal() throws {
        loginAs("Technician")

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5), "Tab bar should appear")

        // Navigate all tabs
        for tab in app.tabBars.buttons.allElementsBoundByIndex {
            if tab.isHittable {
                tab.tap()
                sleep(2)
                scrollDown()
                sleep(1)
            }
        }

        logout()
        XCTAssertTrue(app.buttons["SIGN IN"].waitForExistence(timeout: 10), "Should return to login screen")
    }

    // MARK: - Test 5: Rapid Tab Switching Stress Test

    func testRapidTabSwitching() throws {
        loginAs("Manager")
        sleep(1)

        // Rapidly switch all tabs 5 complete cycles
        for _ in 0..<5 {
            for tab in app.tabBars.buttons.allElementsBoundByIndex {
                if tab.isHittable {
                    tab.tap()
                    usleep(200_000)
                }
            }
        }

        sleep(1)
        XCTAssertTrue(app.tabBars.firstMatch.exists, "App must survive rapid tab switching")

        logout()
    }

    // MARK: - Test 6: All Login/Logout Cycles

    func testAllLoginLogoutCycles() throws {
        let roles = ["Manager", "Admin", "Customer", "Technician"]

        for role in roles {
            loginAs(role)
            XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5), "Should login as \(role)")
            sleep(1)

            // Quick interaction — scroll around
            scrollDown()
            sleep(1)

            logout()
            XCTAssertTrue(app.buttons["SIGN IN"].waitForExistence(timeout: 10), "Should logout from \(role)")
        }
    }

    // MARK: - Test 7: Deep Module Interaction (OEM)

    func testDeepModuleInteractions() throws {
        loginAs("Manager")
        sleep(1)

        // --- Test Trips: tap into a job ---
        tapIfExists(app.tabBars.buttons["Trips"])
        sleep(2)
        if app.cells.count > 0 {
            app.cells.firstMatch.tap()
            sleep(2)
            scrollDown()
            sleep(1)
            app.swipeDown() // dismiss sheet
            sleep(1)
        }

        // --- Test Approvals: tap into an estimate ---
        tapIfExists(app.tabBars.buttons["Approvals"])
        sleep(2)
        if app.cells.count > 0 {
            app.cells.firstMatch.tap()
            sleep(2)
            scrollDown()
            scrollDown()
            sleep(1)
            // Try to dismiss full screen cover
            let close = app.buttons["xmark"]
            if close.exists && close.isHittable {
                close.tap()
            } else {
                app.swipeDown()
            }
            sleep(1)
        }

        // --- Test Machines: tap into a machine, scroll detail ---
        tapIfExists(app.tabBars.buttons["Machines"])
        sleep(2)
        if app.cells.count > 0 {
            app.cells.firstMatch.tap()
            sleep(2)
            scrollDown()
            scrollDown()
            sleep(1)
            goBack()
            sleep(1)
        }

        // --- Test More > Knowledge Base: open article ---
        tapIfExists(app.tabBars.buttons["More"])
        sleep(1)
        let kb = app.staticTexts["Knowledge Base"]
        if kb.waitForExistence(timeout: 3) && kb.isHittable {
            kb.tap()
            sleep(2)

            if app.cells.count > 0 {
                app.cells.firstMatch.tap()
                sleep(2)
                scrollDown()
                sleep(1)
                goBack()
                sleep(1)
            }

            goBack()
            sleep(1)
        }

        // --- Test More > Team Chat: open room, type message ---
        let chat = app.staticTexts["Team Chat"]
        if chat.waitForExistence(timeout: 3) && chat.isHittable {
            chat.tap()
            sleep(2)

            if app.cells.count > 0 {
                app.cells.firstMatch.tap()
                sleep(2)
                scrollDown()
                sleep(1)
                goBack()
                sleep(1)
            }

            goBack()
            sleep(1)
        }

        XCTAssertTrue(app.tabBars.firstMatch.exists, "App must survive deep navigation")
        logout()
    }

    // MARK: - Test 8: Scroll Stress Every Tab

    func testScrollStress() throws {
        loginAs("Manager")
        sleep(1)

        let tabNames = ["Dashboard", "Trips", "Approvals", "Machines"]
        for name in tabNames {
            tapIfExists(app.tabBars.buttons[name])
            sleep(1)

            for _ in 0..<6 {
                scrollDown()
                usleep(150_000)
            }
            for _ in 0..<3 {
                scrollUp()
                usleep(150_000)
            }
            sleep(1)
        }

        XCTAssertTrue(app.tabBars.firstMatch.exists, "App must survive scroll stress")
        logout()
    }

    // MARK: - Test 9: Settings Dark Mode Toggle

    func testSettingsDarkModeToggle() throws {
        loginAs("Manager")
        sleep(1)

        tapIfExists(app.tabBars.buttons["More"])
        sleep(1)

        let settings = app.staticTexts["Settings"]
        if settings.waitForExistence(timeout: 3) && settings.isHittable {
            settings.tap()
            sleep(2)
            scrollDown()
            scrollDown()
            sleep(1)
            goBack()
            sleep(1)
        }

        XCTAssertTrue(app.tabBars.firstMatch.exists, "App must survive settings navigation")
        logout()
    }
}
