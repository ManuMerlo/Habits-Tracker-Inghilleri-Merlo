@testable import HabitsTracker

import XCTest

// Naming Structure: test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct]_[ui component]_[expected result]
// Testing Structure: Given, When, Then


class GeneralView_UITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
    }
    
    func test_GeneralView_GeneralFlow() {
        
        signIn(email: "tony.stark@gmail.com", password: "tony.stark")
        
        Thread.sleep(forTimeInterval: 2)
        
        let tabBar = app.tabBars["Tab Bar"]
        let dashboard = tabBar.buttons["Dashboard"]
        let search = tabBar.buttons["Search"]
        let leaderboard =  tabBar.buttons["Leaderboard"]
        let settings = tabBar.buttons["Settings"]
        
        Thread.sleep(forTimeInterval: 2)
        XCTAssertTrue(dashboard.exists)
        XCTAssertTrue(search.exists)
        XCTAssertTrue(leaderboard.exists)
        XCTAssertTrue(settings.exists)
           
        search.tap()
        let searchlist = app.scrollViews["SearchList"]
        Thread.sleep(forTimeInterval: 2)
        XCTAssertTrue(searchlist.exists)
        
        dashboard.tap()
        let homeTitle = app.staticTexts["HomeTitle"]
        Thread.sleep(forTimeInterval: 2)
        XCTAssertTrue(homeTitle.exists)
        
        leaderboard.tap()
        let leaderboardList = app.scrollViews["LeaderboardList"]
        Thread.sleep(forTimeInterval: 2)
        XCTAssertTrue(leaderboardList.exists)
        
        settings.tap()
        let settingsTitle = app.staticTexts["SettingsTitle"]
        Thread.sleep(forTimeInterval: 2)
        XCTAssertTrue(settingsTitle.exists)
        
        logout()

    }
}

// MARK: FUNCTIONS
extension GeneralView_UITests{
    
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
        app/*@START_MENU_TOKEN@*/.buttons["Logout"]/*[[".cells.buttons[\"Logout\"]",".buttons[\"Logout\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
}
