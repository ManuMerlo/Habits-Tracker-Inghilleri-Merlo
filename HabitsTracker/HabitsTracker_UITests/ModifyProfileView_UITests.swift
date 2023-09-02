//
//  ModifyProfileView_UITests.swift
//  HabitsTracker_UITests
//
//  Created by Manuela Merlo on 01/09/23.
//

@testable import HabitsTracker

import XCTest

// Naming Structure: test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct]_[ui component]_[expected result]
// Testing Structure: Given, When, Then


class ModifyProfileView_UITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        goToModifyProfile()
    }
    
    override func tearDownWithError() throws {
        logout()
    }
    
    func test_ModifyProfileView_ToggleEdit_Todo_ButtonChanges() {
        //Given : we are in the settings view
        //Go to the modify profile view
        let modifyProfileButton = app.scrollViews.otherElements.collectionViews.buttons["Modify profile"]
        
        Thread.sleep(forTimeInterval: 2)
        
        modifyProfileButton.tap()
        
        Thread.sleep(forTimeInterval: 2)
        
        //Tap con edit button
        let editButton = app.buttons["Edit"]
        editButton.tap()
        
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.exists)
        
        doneButton.tap()
        XCTAssertTrue(editButton.exists)
        
        //Go back to settings view
        let backButton = app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"]
        backButton.tap()
    }
    
    func test_ModifyProfileView_DatePickerIsVisibleWhenTapped() {
        //Given : we are in the settings view
        //Go to the modify profile view
        let modifyProfileButton = app.scrollViews.otherElements.collectionViews.buttons["Modify profile"]
        
        Thread.sleep(forTimeInterval: 2)
        
        modifyProfileButton.tap()
        
        Thread.sleep(forTimeInterval: 2)
        
        //Tap con edit button
        let editButton = app.buttons["Edit"]
        editButton.tap()
        
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.exists)
        
        let birthdateRow = app.buttons["Birthdate"]
        birthdateRow.tap()
        
        let datePicker = app.datePickers.firstMatch
        XCTAssertTrue(datePicker.exists)
        
        let doneButtonPicker = app.otherElements["SettingsView"].children(matching: .other).element.buttons["Done"]
        doneButtonPicker.tap()
        
        XCTAssertFalse(datePicker.exists)
        
        doneButton.tap()
        
        birthdateRow.tap()
        
        XCTAssertFalse(datePicker.exists)
        
        let backButton = app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"]
        backButton.tap()

    }
    
    func test_ModifyProfileView_ChangeProfilePictureOpensImagePicker() {
        //Given : we are in the settings view
        //Go to the modify profile view
        
        let modifyProfileButton = app.scrollViews.otherElements.collectionViews.buttons["Modify profile"]
        
        Thread.sleep(forTimeInterval: 2)
        
        modifyProfileButton.tap()
        
        Thread.sleep(forTimeInterval: 2)
        
        let changePhotoButton = app.scrollViews["ModifyProfileScrollView"].otherElements.buttons["Change photo"]
        
        changePhotoButton.tap()
        
        let sheet = app.otherElements["Photos"].children(matching: .other).element.children(matching: .scrollView).element
        
        Thread.sleep(forTimeInterval: 2)
        
        XCTAssertTrue(sheet.exists)
        
        let CancelButton = app.buttons["Cancel"]
        
        CancelButton.tap()
        
        let backButton = app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"]
        backButton.tap()
        
        
      }
    
    func test_ModifyProfileView_HeightPickerIsVisibleWhenTapped() {
        //Given : we are in the settings view
        //Go to the modify profile view
        let modifyProfileButton = app.scrollViews.otherElements.collectionViews.buttons["Modify profile"]
        
        Thread.sleep(forTimeInterval: 2)
        
        modifyProfileButton.tap()
        
        Thread.sleep(forTimeInterval: 2)
        
        //Tap con edit button
        let editButton = app.buttons["Edit"]
        editButton.tap()
        
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.exists)
        
        let heigthButton = app.scrollViews["ModifyProfileScrollView"].otherElements.collectionViews.buttons["Height"]
        heigthButton.tap()
         
        let doneButtonPicker = app.otherElements["SettingsView"].children(matching: .other).element.buttons["Done"]
        
        doneButtonPicker.tap()
       
        doneButton.tap()
    
        let backButton = app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["Back"]
        backButton.tap()
    }
    
    
}

// MARK: FUNCTIONS
extension ModifyProfileView_UITests {
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

    func goToModifyProfile (){
        signIn(email: "tony.stark@gmail.com", password: "tony.stark")
        
        app.tabBars["Tab Bar"].buttons["Settings"].tap()
        
    }
    
    func logout(){
       
        app.tabBars["Tab Bar"].buttons["Settings"].tap()
        app.buttons["Logout"].tap()
    }
}


