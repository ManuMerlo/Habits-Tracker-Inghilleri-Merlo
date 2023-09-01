@testable import HabitsTracker

import XCTest

// Naming Structure: test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct]_[ui component]_[expected result]
// Testing Structure: Given, When, Then


class SettingsView_UITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
    }
    
    func test_SettingsView_GeneralFlow() {
        
        signIn(email: "tony.stark@gmail.com", password: "tony.stark")
        
        app.tabBars["Tab Bar"].buttons["Settings"].tap()
        
        let modifyProfileButton = app.scrollViews.otherElements.collectionViews.buttons["Modify profile"]
        
        Thread.sleep(forTimeInterval: 2)
        
        modifyProfileButton.tap()
        
        Thread.sleep(forTimeInterval: 2)
        
        XCTAssertTrue(app.scrollViews["ModifyProfileScrollView"].exists)
        
        let backButton = app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"]
        
        backButton.tap()
        
        Thread.sleep(forTimeInterval: 2)
        
        XCTAssertTrue(app.scrollViews["SettingsScrollView"].exists)
        
        let providersButton = app.scrollViews.otherElements.collectionViews.buttons["Providers"]
        
        providersButton.tap()
        
        Thread.sleep(forTimeInterval: 2)

        XCTAssertTrue(app.collectionViews["ProvidersVStack"].exists)
        
        backButton.tap()
        
        Thread.sleep(forTimeInterval: 2)
        
        XCTAssertTrue(app.scrollViews["SettingsScrollView"].exists)
        
        
        let notificationButton = app.scrollViews.otherElements.collectionViews.buttons["Notifications"]
        
        notificationButton.tap()
        
        Thread.sleep(forTimeInterval: 2)
        
        XCTAssertTrue(app.collectionViews["NotificationVStack"].exists)
        
        backButton.tap()
        
        Thread.sleep(forTimeInterval: 2)
        
        XCTAssertTrue(app.scrollViews["SettingsScrollView"].exists)
        
        let deleteAccountButton = app.scrollViews.otherElements.collectionViews.buttons["Delete Account"]
        
        deleteAccountButton.tap()
        
        let alert = app.alerts["Delete Account"]
        
        XCTAssertTrue(alert.exists)
        
        alert.scrollViews.otherElements.buttons["Cancel"].tap()
        
        Thread.sleep(forTimeInterval: 2)
        
        XCTAssertFalse(alert.exists)
        
        logout()
                
    }
}

// MARK: FUNCTIONS
extension SettingsView_UITests{
    func signIn(email: String, password: String) {
        app.buttons["Skip"].tap()
        
        // Tap the "Email" text field and enter an email address
        let emailTextField = app.textFields["SignInEmail"]
        emailTextField.tap()
        emailTextField.typeText(email)

        // Tap the "Password" text field and enter a password
        let passwordTextField = app.secureTextFields["SignInPassword"]
        passwordTextField.tap()
        passwordTextField.typeText(password)
        // Tap the "Sign in" button
        app.buttons["Sign in"].tap()
    }
    
    func logout(){
        app.tabBars["Tab Bar"].buttons["Settings"].tap()
        app.buttons["Logout"].tap()
    }
}

