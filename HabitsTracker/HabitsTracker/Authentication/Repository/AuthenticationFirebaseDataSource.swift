import Foundation
import FirebaseAuth

// MARK: - AuthenticationFirebaseDataSource Class

final class AuthenticationFirebaseDataSource: AuthenticationDataSource {
    private let facebookAuthentication = FacebookAuthentication()
    private let googleAuthentication = GoogleAuthentication()
    
    /// Retrieves the currently authenticated user.
    ///
    /// - Throws: `AuthenticationError.userNotLogged` if the user is not currently logged in.
    ///
    /// - Returns: An authenticated `User` object.
    func getAuthenticatedUser() throws -> User {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw AuthenticationError.userNotLogged
        }
        return User(id: user.uid, email: email)
    }
    
    /// Creates a new user with the given email and password.
    ///
    /// - Parameters:
    ///     - email: The email address of the user.
    ///     - password: The password for the user.
    ///
    /// - Throws: Any errors encountered during account creation.
    ///
    /// - Returns: The newly created `User` object.
    func createNewUser(email: String, password: String) async throws -> User {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return User(id: authDataResult.user.uid, email: authDataResult.user.email ?? "")
    }
    
    /// Sends a password reset email to the specified email address.
    ///
    /// - Parameter email: The email address to send the reset password email to.
    ///
    /// - Throws: Any errors encountered during the reset password operation.
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    /// Updates the password of the currently authenticated user.
    ///
    /// - Parameter password: The new password for the user.
    ///
    /// - Throws: `AuthenticationError.userNotLogged` if the user is not currently logged in or any other errors encountered during the update operation.
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotLogged
        }
        try await user.updatePassword(to: password)
    }
    
    /// Updates the email of the currently authenticated user.
    ///
    /// - Parameter email: The new email address for the user.
    ///
    /// - Throws: `AuthenticationError.userNotLogged` if the user is not currently logged in or any other errors encountered during the update operation.
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotLogged
        }
        
        try await user.updateEmail(to: email)
    }
    
    /// Logs in a user using the provided email and password.
    ///
    /// - Parameters:
    ///     - email: The email address of the user.
    ///     - password: The password for the user.
    ///
    /// - Throws: Any errors encountered during the login process.
    ///
    /// - Returns: The authenticated `User` object.
    func login(email: String, password: String) async throws -> User {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return User(id: authDataResult.user.uid, email: authDataResult.user.email ?? "")
    }
    
    /// Logs in a user via Facebook and retrieves their user data.
    ///
    /// - Throws: Any errors encountered during the Facebook login process.
    ///
    /// - Returns: The authenticated `User` object.
    func loginFacebook() async throws -> User {
        let accessToken = try await facebookAuthentication.loginFacebook()
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        let authDataResult: AuthDataResult = try await Auth.auth().signIn(with: credential)
        return User(id: authDataResult.user.uid, email: authDataResult.user.email ?? "")
    }
    
    /// Logs in a user via Google and retrieves their user data.
    ///
    /// - Throws: Any errors encountered during the Google login process.
    ///
    /// - Returns: The authenticated `User` object.
    func loginGoogle() async throws -> User {
        let user = try await googleAuthentication.loginGoogle()
        let idToken = user.authentication.idToken ?? "No idToken"
        let accessToken = user.authentication.accessToken
        let credential: AuthCredential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let authDataResult: AuthDataResult = try await Auth.auth().signIn(with: credential)
        return User(id: authDataResult.user.uid, email: authDataResult.user.email ?? "")
    }
    
    /// Links the authenticated user's account with Google.
    ///
    /// - Throws: Any errors encountered during the linking process.
    func linkGoogle() async throws {
        guard let userAuth = Auth.auth().currentUser else {
            throw AuthenticationError.userNotLogged
        }
        let user = try await googleAuthentication.loginGoogle()
        let idToken = user.authentication.idToken ?? "No idToken"
        let accessToken = user.authentication.accessToken
        let credential: AuthCredential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        try await userAuth.link(with: credential)
    }
    
    /// Logs out the currently authenticated user.
    ///
    /// - Throws: Any errors encountered during the logout process.
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    /// Retrieves a list of accounts linked to the current user.
    ///
    /// - Returns: An array of `LinkedAccounts` associated with the user.
    func getCurrentProvider() -> [LinkedAccounts] {
        guard let currentUser = Auth.auth().currentUser else {
            return []
        }
        let linkedAccounts = currentUser.providerData.map{ userInfo in
            LinkedAccounts(rawValue: userInfo.providerID)
        }.compactMap{ $0 }
        return linkedAccounts
    }
    
    /// Links the authenticated user's account with Facebook.
    ///
    /// - Throws: Any errors encountered during the linking process.
    func linkFacebook() async throws {
        guard let userAuth = Auth.auth().currentUser else {
            throw AuthenticationError.userNotLogged
        }
        let accessToken = try await facebookAuthentication.loginFacebook()
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        try await userAuth.link(with: credential)
    }
    
    /// Retrieves the current authentication credentials of the user.
    ///
    /// - Returns: The current `AuthCredential` of the user or `nil` if none exist.
    func getCurrentCredential() -> AuthCredential? {
        guard let providerId = getCurrentProvider().last else {
            return nil
        }
        switch providerId {
        case .facebook:
            guard let accessToken = facebookAuthentication.getAccessToken() else {
                return nil
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
            return credential
        case .google:
            guard let user = googleAuthentication.getUser() else{
                return nil
            }
            let idToken = user.authentication.idToken ?? "No idToken"
            let accessToken = user.authentication.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            return credential
        case .emailAndPassword,.unknown:
            return nil
        }
    }
    
    /// Links the authenticated user's account with the provided email and password.
    ///
    /// - Parameters:
    ///     - email: The email address to link.
    ///     - password: The password to link.
    ///
    /// - Throws: Any errors encountered during the linking process.
    func linkEmailAndPassword(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotLogged
        }
        guard let credential = getCurrentCredential() else {
            throw AuthenticationError.missingCredential
        }
        try await user.reauthenticate(with: credential)
        let emailAndPasswordCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.link(with: emailAndPasswordCredential)
    }
    
    /// Deletes the currently authenticated user from Firebase.
    ///
    /// - Throws: Any errors encountered during the deletion process.
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotLogged
        }
        try await user.delete()
    }
}

