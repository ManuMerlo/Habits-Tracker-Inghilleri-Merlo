import XCTest

import XCTest

// Naming Structure: test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct]_[ui component]_[expected result]
// Testing Structure: Given, When, Then


class SignInView_UITests: XCTestCase {

    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
//        app.launchArguments = ["-UITest_startSignIn"]
//        app.launchEnvironment = ["-UITest_startSignedIn2" : "true"]
        app.launch()
    }

    override func tearDownWithError() throws {
    }

    func test_SignInView_signUpButton_shouldNotSignInWithEmptyFields() {
        // Given
    
        // When
        signIn(email: "", password: "")
        
        // Then
        let errorText = app/*@START_MENU_TOKEN@*/.staticTexts["MessageErrorSignIn"]/*[[".staticTexts[\"Empty email or password\"]",".staticTexts[\"MessageErrorSignIn\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
     
        XCTAssertEqual(errorText.label, "Empty email or password")
    }
    
    func test_SignInView_signUpButton_shouldNotSignInWithWrongCredentials() {
        // Given
    
        // When
        signIn(email: "test@test.com", password: "test")
        
        // Then
        let errorText = app/*@START_MENU_TOKEN@*/.staticTexts["MessageErrorSignIn"]/*[[".staticTexts[\"Empty email or password\"]",".staticTexts[\"MessageErrorSignIn\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
     
        XCTAssertEqual(errorText.label, "Login error. Retry.")
    }
    
    func test_SignInView_signUpButton_shouldSignIn() {
        //Given
        
        signIn(email: "tony.stark@gmail.com", password: "tony.stark")
        
        // Assert that you are on the "Dashboard" screen
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(app.staticTexts["HomeTitle"].exists)
        
        logout()
    }
    
    func test_SignInView_navigationLink_shouldShowSignUpView() {
        app.buttons["Skip"].tap()
        
        let scrollViews = app.scrollViews
        //Swipe up to show the navigation link
        scrollViews.otherElements.containing(.staticText, identifier:"Sign in").element.swipeUp()
        let navigationButton = app.buttons["navigationLinkSignUp"]
        //Tap on the navigation Link
        navigationButton.tap()
        
        //Wait and assert to be in the SignUp view
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(app.staticTexts["SignUpTitle"].exists)
        
        //Tab the navigation bar to come back
        app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"].tap()
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(app.staticTexts["SignInTitle"].exists)
        
    }
}

// MARK: FUNCTIONS
extension SignInView_UITests {
    
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
