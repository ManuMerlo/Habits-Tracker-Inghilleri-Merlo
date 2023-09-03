@testable import HabitsTracker

import XCTest

// Naming Structure: test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct]_[ui component]_[expected result]
// Testing Structure: Given, When, Then


class RequestListView_UITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        if app.tabBars["Tab Bar"].buttons["Settings"].exists{
            logout()
        }
        
        Thread.sleep(forTimeInterval: 3)
        
        signIn(email: "tony.stark@gmail.com", password: "tony.stark")
    }
    
    override func tearDownWithError() throws {
        if app.tabBars["Tab Bar"].buttons["Settings"].exists{
            logout()
        }
    }
    
    func test_RequestListView_FlowFromDashboard() {
        
        let heartButton = app.buttons["heartButton"]
        heartButton.tap()
        
        XCTAssertTrue(app.scrollViews["RequestListScrollView"].exists)
        
        XCTAssertTrue(app.buttons["Confirm"].exists)
        
        XCTAssertTrue(app.buttons["Remove"].exists)
    }
        
}

// MARK: FUNCTIONS
extension RequestListView_UITests {
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


