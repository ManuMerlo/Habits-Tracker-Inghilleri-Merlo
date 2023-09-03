/// `AuthenticationRepository` provides methods to interact with authentication-related operations.
///
/// This class abstracts the underlying data source (`AuthenticationFirebaseDataSource` in this case),
/// making it easier to potentially swap or modify the data source without affecting consumers of the repository.
final class AuthenticationRepository {
    
    private let authenticationFirebaseDataSource: AuthenticationDataSource
    
    /// Initializes a new instance of `AuthenticationRepository` with the default `AuthenticationFirebaseDataSource`.
    init(authenticationFirebaseDataSource: AuthenticationFirebaseDataSource = AuthenticationFirebaseDataSource()) {
        self.authenticationFirebaseDataSource = authenticationFirebaseDataSource
    }
    
    /// Initializes a new instance of `AuthenticationRepository` with a provided data source.
    /// This is used for testing purposes to inject mock data sources.
    ///
    /// - Parameters:
    ///   - authenticationFirebaseDataSource: The data source to be used by the repository.
    init(withDataSource authenticationFirebaseDataSource: AuthenticationDataSource) {
        self.authenticationFirebaseDataSource = authenticationFirebaseDataSource
    }
    
    /// Retrieves the currently authenticated user.
    ///
    /// - Throws: Any errors encountered during the process.
    ///
    /// - Returns: The authenticated `User` object.
    func getAuthenticatedUser() throws -> User {
        return try authenticationFirebaseDataSource.getAuthenticatedUser()
    }
    
    /// Registers a new user with the provided email and password.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///
    /// - Throws: Any errors encountered during user creation.
    ///
    /// - Returns: The newly created `User` object.
    func createNewUser(email: String, password: String) async throws -> User {
        return try await authenticationFirebaseDataSource.createNewUser(email: email, password: password)
    }
    
    /// Sends a password reset instruction to the given email.
    ///
    /// - Parameter email: The user's email address.
    ///
    /// - Throws: Any errors encountered during the process.
    func resetPassword(email: String) async throws {
        try await authenticationFirebaseDataSource.resetPassword(email: email)
    }
    
    /// Updates the authenticated user's email.
    ///
    /// - Parameter email: The new email address.
    ///
    /// - Throws: Any errors encountered during the update.
    func updateEmail(email: String) async throws {
        try await authenticationFirebaseDataSource.updateEmail(email: email)
    }
    
    /// Updates the authenticated user's password.
    ///
    /// - Parameter password: The new password.
    ///
    /// - Throws: Any errors encountered during the update.
    func updatePassword(password: String) async throws {
        try await authenticationFirebaseDataSource.updatePassword(password: password)
    }
    
    /// Logs in a user with the provided email and password.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///
    /// - Throws: Any errors encountered during login.
    ///
    /// - Returns: The authenticated `User` object.
    func login(email: String, password: String) async throws -> User {
        return try await authenticationFirebaseDataSource.login(email: email, password: password)
    }
    
    /// Logs in a user via Facebook authentication.
    ///
    /// - Throws: Any errors encountered during the process.
    ///
    /// - Returns: The authenticated `User` object.
    func loginFacebook() async throws -> User {
        return try await authenticationFirebaseDataSource.loginFacebook()
    }
    
    /// Logs in a user via Google authentication.
    ///
    /// - Throws: Any errors encountered during the process.
    ///
    /// - Returns: The authenticated `User` object.
    func loginGoogle() async throws -> User {
        return try await authenticationFirebaseDataSource.loginGoogle()
    }
    
    /// Logs out the currently authenticated user.
    ///
    /// - Throws: Any errors encountered during the process.
    func logout() throws {
        try authenticationFirebaseDataSource.logout()
    }
    
    /// Retrieves the authentication providers linked with the current user.
    ///
    /// - Returns: A list of `LinkedAccounts` associated with the authenticated user.
    func getCurrentProvider() -> [LinkedAccounts] {
        authenticationFirebaseDataSource.getCurrentProvider()
    }
    
    /// Links the authenticated user's account with Facebook.
    ///
    /// - Throws: Any errors encountered during the process.
    func linkFacebook() async throws {
        try await authenticationFirebaseDataSource.linkFacebook()
    }
    
    /// Links the authenticated user's account with Google.
    ///
    /// - Throws: Any errors encountered during the process.
    func linkGoogle() async throws {
        try await authenticationFirebaseDataSource.linkGoogle()
    }
    
    /// Links the authenticated user's account with an email and password.
    ///
    /// - Parameters:
    ///   - email: The email address.
    ///   - password: The password.
    ///
    /// - Throws: Any errors encountered during the process.
    func linkEmailAndPassword(email: String, password: String) async throws {
        try await authenticationFirebaseDataSource.linkEmailAndPassword(email:email,
                                                                        password: password)
    }
    
    /// Deletes the authenticated user's account.
    ///
    /// - Throws: Any errors encountered during deletion.
    func deleteUser() async throws {
        try await authenticationFirebaseDataSource.deleteUser()
    }
}
