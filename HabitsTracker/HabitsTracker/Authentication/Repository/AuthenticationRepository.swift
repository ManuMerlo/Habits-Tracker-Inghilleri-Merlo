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
    
    func createNewUser(email: String, password: String) async throws -> User {
        return try await authenticationFirebaseDataSource.createNewUser(email: email, password: password)
    }
    
    func resetPassword(email: String) async throws {
        try await authenticationFirebaseDataSource.resetPassword(email: email)
    }
    
    func updateEmail(email: String) async throws {
        try await authenticationFirebaseDataSource.updateEmail(email: email)
    }
    
    func updatePassword(password: String) async throws {
        try await authenticationFirebaseDataSource.updatePassword(password: password)
    }
    
    func login(email: String, password: String) async throws -> User {
        return try await authenticationFirebaseDataSource.login(email: email, password: password)
    }
    
    func loginFacebook() async throws -> User {
        return try await authenticationFirebaseDataSource.loginFacebook()
    }
    
    func loginGoogle() async throws -> User {
        return try await authenticationFirebaseDataSource.loginGoogle()
    }
    
    func logout() throws {
        try authenticationFirebaseDataSource.logout()
    }
    
    func getCurrentProvider() -> [LinkedAccounts] {
        authenticationFirebaseDataSource.getCurrentProvider()
    }
    
    func linkFacebook() async throws {
        try await authenticationFirebaseDataSource.linkFacebook()
    }
    
    func linkGoogle() async throws {
        try await authenticationFirebaseDataSource.linkGoogle()
    }
    
    func linkEmailAndPassword(email: String, password: String) async throws {
        try await authenticationFirebaseDataSource.linkEmailAndPassword(email:email,
                                                              password: password)
    }

    func deleteUser() async throws {
        try await authenticationFirebaseDataSource.deleteUser()
    }
}
