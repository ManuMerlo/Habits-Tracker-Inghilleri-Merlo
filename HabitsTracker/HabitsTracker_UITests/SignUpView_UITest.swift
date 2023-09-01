import XCTest

import XCTest

// Naming Structure: test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct]_[ui component]_[expected result]
// Testing Structure: Given, When, Then


class SignUpView_UITests: XCTestCase {

    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
//        app.launchArguments = ["-UITest_startSignIn"]
//        app.launchEnvironment = ["-UITest_startSignedIn2" : "true"]
        app.launch()
    }

    override func tearDownWithError() throws {
    }
  
    func test_SignUpView_signUpButton_shouldSignUp() {
        //Given
        goToSignUp()
        
        //When
        let username = UUID().uuidString.prefix(7)
        signUp(username: String(username), email: "\(username)@testemail.com", password: "\(username)Password", repeatPassword: "\(username)Password")
        
        // Assert that you are on the "Dashboard" screen
        Thread.sleep(forTimeInterval: 5)
        
        XCTAssertTrue(app.staticTexts["HomeTitle"].exists)
        
        logout()
    }
    
    func test_SignUpView_messageErrorTextField_ShouldDisplayErrors(){
        //Given
        goToSignUp()
        
        //When
        // isValidEmail
        // textFieldPassword.isEmpty
        // repeatPassword.isEmpty
        // error : "Not valid email or empty password"
        signUp(username: "username", email: "@gmail.com", password: "password", repeatPassword: "password")
        
        let errorText = app.staticTexts["MessageErrorSignUp"]
     
        XCTAssertEqual(errorText.label, "Not valid email or empty password")
        
        signUp(username: "username", email: "username@gmail.com", password: "", repeatPassword: "")
        
        XCTAssertEqual(errorText.label, "Not valid email or empty password")
        
        // textFieldPassword == repeatPassword else {
        // error ; "Passwords do not match"
        
        signUp(username: "username", email: "username@gmail.com", password: "password", repeatPassword: "pass")
        
        XCTAssertEqual(errorText.label, "Passwords do not match")
        
        // textFieldUsername.isEmpty
        // error =  "Username is empty"
        
        signUp(username:"", email: "username@gmail.com", password: "password", repeatPassword: "password")
        
        XCTAssertEqual(errorText.label, "Username is empty")
        
        // email is present
        // error: "The email already exists."
        
        signUp(username: "tony", email: "tony.stark@gmail.com", password: "password", repeatPassword: "password")
        
        //Wait for the API
        Thread.sleep(forTimeInterval: 5)
        XCTAssertEqual(errorText.label, "The email already exists.")
        
        // username is present
        // error : "The username already exists."
        
        signUp(username: "StarkTechGenius", email: "tony.stark.new@gmail.com", password: "password", repeatPassword: "password")
        
        //Wait for the API
        Thread.sleep(forTimeInterval: 5)
        XCTAssertEqual(errorText.label, "The username already exists.")
        
        app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"].tap()
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(app.staticTexts["SignInTitle"].exists)
    }

}

// MARK: FUNCTIONS

extension SignUpView_UITests {
    
    func goToSignUp(){
        app.buttons["Skip"].tap()
        let scrollViews = app.scrollViews
        //Swipe up to show the navigation link
        scrollViews.otherElements.containing(.staticText, identifier:"Sign in").element.swipeUp()
        let navigationButton = app.buttons["navigationLinkSignUp"]
        navigationButton.tap()
    }
    
    func signUp(username: String, email: String, password: String, repeatPassword : String) {
        // Tap the "Username" text field and enter a username
        let usernameTextField = app.textFields["SignUpUsername"]
        usernameTextField.tap()
        usernameTextField.clearAndEnterText(text: username)

        
        // Tap the "Email" text field and enter an email address
        let emailTextField = app.textFields["SignUpEmail"]
        emailTextField.tap()
        emailTextField.clearAndEnterText(text: email)

        // Tap the "Password" text field and enter a password
        let passwordTextField = app.secureTextFields["SignUpPassword"]
        passwordTextField.tap()
        passwordTextField.clearAndEnterText(text: password)
        
        let repeatPasswordTextField = app.secureTextFields["SignUpRepeatPassword"]
        repeatPasswordTextField.tap()
        repeatPasswordTextField.clearAndEnterText(text: repeatPassword)
        
        // Tap the "Sign un" button
        app.buttons["Sign up"].tap()
    }
    
    func logout(){
        app.tabBars["Tab Bar"].buttons["Settings"].tap()
        app/*@START_MENU_TOKEN@*/.buttons["Logout"]/*[[".cells.buttons[\"Logout\"]",".buttons[\"Logout\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
    
}

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) {
        self.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        self.typeText(XCUIKeyboardKey.delete.rawValue)
        self.typeText(text)
    }
}
