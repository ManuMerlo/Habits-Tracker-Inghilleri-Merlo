
import Foundation
import FirebaseAuth
@testable import HabitsTracker

final class MockAuthenticationDataSource : AuthenticationDataSource{
    
    var authenticatedUser: HabitsTracker.User?
    var linkedAccounts: [LinkedAccounts] = []
    var authCredential: AuthCredential?
    var throwErrors: Bool = false
    
    init(authenticatedUser: HabitsTracker.User? = nil,
         linkedAccounts: [LinkedAccounts] = [],
         authCredential: AuthCredential? = nil,
         throwErrors: Bool = false) {
        
        self.authenticatedUser = authenticatedUser
        self.linkedAccounts = linkedAccounts
        self.authCredential = authCredential
        self.throwErrors = throwErrors
    }
    
    func getAuthenticatedUser() throws -> HabitsTracker.User {
        if throwErrors {
            throw AuthenticationError.userNotLogged
        }
        return authenticatedUser ?? User(id: "mockId", email: "test@test.com")
    }
    
    func createNewUser(email: String, password: String) async throws -> HabitsTracker.User{
        if throwErrors {
            throw AuthenticationError.userNotLogged
        }
        return User(id: "mockId", email: email)
    }
    
    func login(email: String, password: String) async throws -> HabitsTracker.User{
        if throwErrors {
            throw AuthenticationError.userNotLogged
        }
        return User(id: "mockId", email: email)
    }
    
    func loginFacebook() async throws -> HabitsTracker.User {
        if throwErrors {
            throw AuthenticationError.userNotLogged
        }
        return User(id: "facebookId", email: "facebook@test.com")
    }
    
    func loginGoogle() async throws -> HabitsTracker.User {
        if throwErrors {
            throw AuthenticationError.userNotLogged
        }
        return User(id: "googleId", email: "google@test.com")
    }
    
    func linkGoogle() async throws {
        if throwErrors {
            throw AuthenticationError.userNotLogged
        }
    }
    
    func logout() throws {
        if throwErrors {
            throw AuthenticationError.userNotLogged
        }
    }
    
    func getCurrentProvider() -> [LinkedAccounts] {
        return linkedAccounts
    }
    
    func linkFacebook() async throws {
        if throwErrors {
            throw AuthenticationError.userNotLogged
        }
    }
    
    func getCurrentCredential() -> AuthCredential? {
        return authCredential
    }
    
    func linkEmailAndPassword(email: String, password: String) async throws {
        if throwErrors {
            throw AuthenticationError.userNotLogged
        }
    }
    
    func deleteUser() async throws {
        if throwErrors {
            throw AuthenticationError.userNotLogged
        }
    }
}

