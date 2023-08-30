
import XCTest
@testable import HabitsTracker

@MainActor
final class AuthenticationViewModel_Tests: XCTestCase {
    
    var viewModel: AuthenticationViewModel?
    let expectedUser = User(id: "mockId", email: "test@test.com")
    
    override func setUp() {
        super.setUp()
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser)
        viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    
    func test_AuthenticationViewModel_init_correctInitialisationWithUserAuthenticated(){
        //Given
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        //When
        
        //Then
        XCTAssertEqual(viewModel.tasks, [])
        //init() calls getAuthenticatedUsers()
        XCTAssertEqual(viewModel.user?.id, "mockId")
        XCTAssertEqual(viewModel.user?.email, "test@test.com")
        XCTAssertNil(viewModel.messageError)
        XCTAssertFalse(viewModel.isAccountLinked)
        XCTAssertEqual(viewModel.textFieldEmailSignin, "")
        XCTAssertEqual(viewModel.textFieldPasswordSignin, "")
        XCTAssertEqual(viewModel.textFieldUsername, "")
        XCTAssertEqual(viewModel.textFieldEmail, "")
        XCTAssertEqual(viewModel.textFieldPassword, "")
        XCTAssertEqual(viewModel.repeatPassword, "")
        XCTAssertEqual(viewModel.linkedAccounts, [])
        XCTAssertFalse(viewModel.showAlert)
    }
    
    
    func test_AuthenticationViewModel_init_correctInitialisationWithoutUserAuthenticated(){
        //Given
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser,throwErrors: true)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        //When
        
        //Then
        XCTAssertEqual(viewModel.tasks, [])
        //init() calls getAuthenticatedUsers()
        XCTAssertNil(viewModel.user)
        XCTAssertNil(viewModel.messageError)
        XCTAssertFalse(viewModel.isAccountLinked)
        XCTAssertEqual(viewModel.textFieldEmailSignin, "")
        XCTAssertEqual(viewModel.textFieldPasswordSignin, "")
        XCTAssertEqual(viewModel.textFieldUsername, "")
        XCTAssertEqual(viewModel.textFieldEmail, "")
        XCTAssertEqual(viewModel.textFieldPassword, "")
        XCTAssertEqual(viewModel.repeatPassword, "")
        
        XCTAssertEqual(viewModel.linkedAccounts, [])
        XCTAssertFalse(viewModel.showAlert)
    }
    
    func test_AuthenticationViewModel_isValidEmail() {
        // Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        let validEmails = [
            "john.doe@gmail.com",
            "alice.smith@example.org",
            "bob+123@my-website.net",
            "charlie.brown@university.edu",
            "david.miller@company.co.uk"
        ]
        
        let invalidEmails = [
            "john.doe",              // missing @ symbol and domain
            "john.doe@.com",         // missing domain name before .com
            "@gmail.com",            // missing username,
            "john.doe@gmail"        // missing top-level domain .com, .net, etc.
        ]
        
        // Test valid emails
        for email in validEmails {
            XCTAssertTrue(vm.isValidEmail(email: email), "Expected \(email) to be valid")
        }
        
        // Test invalid emails
        for email in invalidEmails {
            XCTAssertFalse(vm.isValidEmail(email: email), "Expected \(email) to be invalid")
        }
    }
    
    func test_AuthenticationViewModel_clearSignUpParameter(){
        // Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        //When
        vm.textFieldUsername = "test"
        vm.textFieldEmail = "tets@gmail.com"
        vm.textFieldPassword = "test"
        vm.repeatPassword = "test"
        vm.messageError = "invalid email"
        
        vm.clearSignUpParameter()
        
        //Then
        XCTAssertEqual(vm.textFieldUsername, "")
        XCTAssertEqual(vm.textFieldEmail, "")
        XCTAssertEqual(vm.textFieldPassword, "")
        XCTAssertEqual(vm.repeatPassword, "")
        XCTAssertNil( vm.messageError)
        
    }
    
    func test_AuthenticationViewModel_clearSignInParameter(){
        // Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        //When
        vm.textFieldEmailSignin = "tets@gmail.com"
        vm.textFieldPasswordSignin = "test"
        vm.messageError = "invalid email"
        
        vm.clearSignInParameter()
        
        //Then
        XCTAssertEqual(vm.textFieldEmailSignin, "")
        XCTAssertEqual(vm.textFieldPasswordSignin, "")
        
    }
    
    func test_AuthenticationViewModel_CreateNewUser_Success() async throws {
        // Given
        guard let viewModel = viewModel else{
            XCTFail()
            return
        }
        viewModel.messageError = ""
        viewModel.textFieldEmail = "test@test.com"
        viewModel.textFieldPassword = "password"
        viewModel.textFieldUsername = "testUser"
        viewModel.repeatPassword = "password"
        
        // When
        let user = try await viewModel.createNewUser()
        
        // Then
        XCTAssertEqual(user.id, expectedUser.id)
        XCTAssertEqual(user.email, expectedUser.email)
        XCTAssertEqual(viewModel.user?.id, expectedUser.id)
        XCTAssertEqual(viewModel.user?.email, expectedUser.email)
    }
    
    func test_AuthenticationViewModel_CreateNewUser_FailureEmptyStrings() async throws {
        // Given
        guard let viewModel = viewModel else{
            XCTFail()
            return
        }
        viewModel.messageError = ""
        viewModel.textFieldEmail = ""
        viewModel.textFieldPassword = ""
        viewModel.textFieldUsername = ""
        viewModel.repeatPassword = ""
        
        // When
        do {
            _ = try await viewModel.createNewUser()
            XCTFail("Expected to throw error")
        } catch let error as ViewError {
            XCTAssertEqual(error, ViewError.usernameEmailPasswordNotFound)
        }
    }
    
    func test_AuthenticationViewModel_CreateNewUser_FailureError() async throws {
        // Given
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser,throwErrors: true)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        viewModel.messageError = ""
        viewModel.textFieldEmail = "test@test.com"
        viewModel.textFieldPassword = "password"
        viewModel.textFieldUsername = "testUser"
        viewModel.repeatPassword = "password"
        
        // When
        do {
            _ = try await viewModel.createNewUser()
            XCTFail("Expected to throw error")
        } catch let error as AuthenticationError{
            XCTAssertEqual(error, AuthenticationError.userNotLogged)
        }
    }
    
    func test_AuthenticationViewModel_Login_Success() async {
        // Given
        guard let viewModel = viewModel else{
            XCTFail()
            return
        }
        
        viewModel.messageError = ""
        viewModel.textFieldEmailSignin = "test@test.com"
        viewModel.textFieldPasswordSignin = "password"
        
        // When
        
        
        viewModel.login()
        let task = viewModel.tasks.last
        let _ = await task?.result
        
        // Then
        
        XCTAssertEqual(viewModel.user?.id, expectedUser.id)
        XCTAssertEqual(viewModel.user?.email, expectedUser.email)
        XCTAssertEqual(viewModel.messageError,"")
    }
    
    func test_AuthenticationViewModel_Login_FailureThrow() async{
        // Given
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser,throwErrors: true)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        viewModel.messageError = ""
        viewModel.textFieldEmailSignin = "test@test.com"
        viewModel.textFieldPasswordSignin = "password"
        
        // When
        viewModel.login()
        
        let task = viewModel.tasks.last
        let _ = await task?.result
        
        // Then
        XCTAssertNil(viewModel.user)
        XCTAssertEqual(viewModel.messageError,"Login error. Retry.")
        
        
    }
    
    func test_AuthenticationViewModel_Login_FailureEmptyCredentials() async {
        //Given
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser,throwErrors: true)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        viewModel.messageError = ""
        viewModel.textFieldEmailSignin = ""
        viewModel.textFieldPasswordSignin = ""
        
        // When
        viewModel.login()
        
        // Then
        XCTAssertNil(viewModel.user)
        XCTAssertEqual(viewModel.messageError,"No username, email or password found.")
    }
    
    func test_AuthenticationViewModel_LoginFacebook_Success() async {
        //Given
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser,throwErrors: false)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        viewModel.messageError = ""
        
        // When
        do {
            let user = try await viewModel.loginFacebook()
            XCTAssertEqual(user.id, "facebookId")
            XCTAssertEqual(user.email, "facebook@test.com")
            XCTAssertEqual(viewModel.user?.id, "facebookId")
            XCTAssertEqual(viewModel.user?.email, "facebook@test.com")
        } catch {
            XCTFail()
        }
    }
    
    func test_AuthenticationViewModel_LoginFacebook_FailureThrow() async {
        //Given
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser,throwErrors: true)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        viewModel.messageError = ""
        
        // When
        do {
            _ = try await viewModel.loginFacebook()
            XCTFail("Expected to throw error")
        } catch let error{
            if let error = error as? AuthenticationError{
                XCTAssertEqual(error, AuthenticationError.userNotLogged)
            } else {
                XCTFail()
            }
        }
    }
    
    func test_AuthenticationViewModel_LoginGoogle_Success() async {
        //Given
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser,throwErrors: false)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        viewModel.messageError = ""
        viewModel.textFieldEmail = "test@test.com"
        viewModel.textFieldPassword = "password"
        viewModel.textFieldUsername = "testUser"
        viewModel.repeatPassword = "password"
        
        // When
        do {
            let user = try await viewModel.loginGoogle()
            XCTAssertEqual(user.id, "googleId")
            XCTAssertEqual(user.email, "google@test.com")
            XCTAssertEqual(viewModel.user?.id, "googleId")
            XCTAssertEqual(viewModel.user?.email, "google@test.com")
        } catch {
            XCTFail()
        }
    }
    
    func test_AuthenticationViewModel_LoginGoogle_FailureThrow() async {
        //Given
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser,throwErrors: true)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        viewModel.messageError = ""
        
        // When
        do {
            _ = try await viewModel.loginGoogle()
            XCTFail("Expected to throw error")
        } catch let error{
            if let error = error as? AuthenticationError{
                XCTAssertEqual(error, AuthenticationError.userNotLogged)
            } else {
                XCTFail()
            }
        }
    }
    
    func test_AuthenticationViewModel_Logout_Success() async {
        //Given
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser,throwErrors: false)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        
        XCTAssertNotNil(viewModel.user)
        viewModel.textFieldEmailSignin = "tets@gmail.com"
        viewModel.textFieldPasswordSignin = "test"
        viewModel.textFieldEmail = "test@test.com"
        viewModel.textFieldPassword = "password"
        viewModel.textFieldUsername = "testUser"
        viewModel.repeatPassword = "password"
        
        // When
        // When
        viewModel.logout()
        
        let task = viewModel.tasks.last
        let _ = await task?.result
        
        XCTAssertNil(viewModel.user)
        XCTAssertEqual(viewModel.textFieldUsername, "")
        XCTAssertEqual(viewModel.textFieldEmail, "")
        XCTAssertEqual(viewModel.textFieldPassword, "")
        XCTAssertEqual(viewModel.repeatPassword, "")
        XCTAssertNil( viewModel.messageError)
        XCTAssertEqual(viewModel.textFieldEmailSignin, "")
        XCTAssertEqual(viewModel.textFieldPasswordSignin, "")
    }
    
    func test_AuthenticationViewModel_Logout_FailureThrow() async {
        //Given
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser,throwErrors: true)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        viewModel.messageError = ""
        viewModel.user = User(id: "mockId", email: "test@test.com")
        
        //When
        viewModel.logout()
        
        let task = viewModel.tasks.last
        let _ = await task?.result
        
        // Then
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.messageError,"Logout error. Retry.")
    }
    
    func test_AuthenticationViewModel_getCurrentProvider(){
        //Given
        let linkedAccounts : [LinkedAccounts] = [.emailAndPassword, .facebook]
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser, linkedAccounts: linkedAccounts)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        //When
        viewModel.getCurrentProvider()
        
        //Then
        XCTAssertEqual(viewModel.linkedAccounts, linkedAccounts)
    }
    
    func test_AuthenticationViewModel_isEmailandPasswordLinked_True(){
        //Given
        let linkedAccounts : [LinkedAccounts] = [.emailAndPassword, .facebook]
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser, linkedAccounts: linkedAccounts)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        //When
        viewModel.getCurrentProvider()
        let result = viewModel.isEmailandPasswordLinked()
        
        //Then
        XCTAssertTrue(result)
    }
    
    func test_AuthenticationViewModel_isEmailandPasswordLinked_False(){
        //Given
        let linkedAccounts : [LinkedAccounts] = [.facebook]
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser, linkedAccounts: linkedAccounts)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        //When
        viewModel.getCurrentProvider()
        let result = viewModel.isEmailandPasswordLinked()
        
        //Then
        XCTAssertFalse(result)
    }
    
    func test_AuthenticationViewModel_isFacebookLinked_True(){
        //Given
        let linkedAccounts : [LinkedAccounts] = [.emailAndPassword, .facebook]
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser, linkedAccounts: linkedAccounts)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        //When
        viewModel.getCurrentProvider()
        let result = viewModel.isFacebookLinked()
        
        //Then
        XCTAssertTrue(result)
    }
    
    func test_AuthenticationViewModel_isFacebookLinked_False(){
        //Given
        let linkedAccounts : [LinkedAccounts] = [.emailAndPassword]
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser, linkedAccounts: linkedAccounts)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        //When
        viewModel.getCurrentProvider()
        let result = viewModel.isEmailandPasswordLinked()
        
        //Then
        XCTAssertFalse(result)
    }
    
    func test_AuthenticationViewModel_isGoogleLinked_True(){
        //Given
        let linkedAccounts : [LinkedAccounts] = [.emailAndPassword, .facebook, .google]
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser, linkedAccounts: linkedAccounts)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        //When
        viewModel.getCurrentProvider()
        let result = viewModel.isGoogleLinked()
        
        //Then
        XCTAssertTrue(result)
    }
    
    func test_AuthenticationViewModel_isGoogleLinked_False(){
        //Given
        let linkedAccounts : [LinkedAccounts] = [.emailAndPassword, .facebook]
        let mockAuthDataSource = MockAuthenticationDataSource(authenticatedUser: expectedUser, linkedAccounts: linkedAccounts)
        let viewModel = AuthenticationViewModel(authenticationRepository: AuthenticationRepository(withDataSource: mockAuthDataSource))
        
        //When
        viewModel.getCurrentProvider()
        let result = viewModel.isGoogleLinked()
        
        //Then
        XCTAssertFalse(result)
    }
}

