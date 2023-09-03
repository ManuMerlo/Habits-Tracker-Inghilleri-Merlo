import Foundation
import FirebaseAuth

// MARK: - AuthenticationDataSource Protocol

protocol AuthenticationDataSource {
    
    /// Retrieves the currently authenticated user.
    ///
    /// - Throws: `AuthenticationError.userNotLogged` if the user is not currently logged in.
    ///
    /// - Returns: An authenticated `User` object.
    func getAuthenticatedUser() throws -> User
    
    /// Creates a new user with the specified email and password.
    ///
    /// - Parameters:
    ///     - email: The email address of the user to create.
    ///     - password: The password for the new user.
    ///
    /// - Throws: Any errors encountered during user creation.
    ///
    /// - Returns: The newly created `User` object.
    func createNewUser(email: String, password: String) async throws -> User
    
    /// Sends a password reset email to the specified email address.
    ///
    /// - Parameter email: The email address to send the reset password email to.
    ///
    /// - Throws: Any errors encountered during the reset password operation.
    func resetPassword(email: String) async throws
    
    /// Updates the password of the currently authenticated user.
    ///
    /// - Parameter password: The new password for the user.
    ///
    /// - Throws: `AuthenticationError.userNotLogged` if the user is not
    /// currently logged in or any other errors encountered during the update operation.
    func updatePassword(password: String) async throws
    
    /// Updates the email of the currently authenticated user.
    ///
    /// - Parameter email: The new email address for the user.
    ///
    /// - Throws: `AuthenticationError.userNotLogged` if the user is not
    /// currently logged in or any other errors encountered during the update operation.
    func updateEmail(email: String) async throws
    
    /// Logs in a user using the provided email and password.
    ///
    /// - Parameters:
    ///     - email: The email address of the user.
    ///     - password: The password for the user.
    ///
    /// - Throws: Any errors encountered during the login process.
    ///
    /// - Returns: The authenticated `User` object.
    func login(email: String, password: String) async throws -> User
    
    /// Logs in a user via Facebook and retrieves their user data.
    ///
    /// - Throws: Any errors encountered during the Facebook login process.
    ///
    /// - Returns: The authenticated `User` object.
    func loginFacebook() async throws -> User
    
    /// Logs in a user via Google and retrieves their user data.
    ///
    /// - Throws: Any errors encountered during the Google login process.
    ///
    /// - Returns: The authenticated `User` object.
    func loginGoogle() async throws -> User
    
    /// Links the authenticated user's account with Google.
    ///
    /// - Throws: Any errors encountered during the linking process.
    func linkGoogle() async throws
    
    /// Logs out the currently authenticated user.
    ///
    /// - Throws: Any errors encountered during the logout process.
    func logout() throws
    
    /// Retrieves a list of accounts linked to the current user.
    ///
    /// - Returns: An array of `LinkedAccounts` associated with the user.
    func getCurrentProvider() -> [LinkedAccounts]
    
    /// Links the authenticated user's account with Facebook.
    ///
    /// - Throws: Any errors encountered during the linking process.
    func linkFacebook() async throws
    
    /// Retrieves the current authentication credentials of the user.
    ///
    /// - Returns: The current `AuthCredential` of the user or `nil` if none exist.
    func getCurrentCredential() -> AuthCredential?
    
    /// Links the authenticated user's account with the provided email and password.
    ///
    /// - Parameters:
    ///     - email: The email address to link.
    ///     - password: The password to link.
    ///
    /// - Throws: Any errors encountered during the linking process.
    func linkEmailAndPassword(email: String, password: String) async throws
    
    /// Deletes the currently authenticated user from Firebase.
    ///
    /// - Throws: Any errors encountered during the deletion process.
    func deleteUser() async throws
}
