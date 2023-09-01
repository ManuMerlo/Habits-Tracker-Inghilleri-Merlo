final class AuthenticationRepository {
    private let authenticationFirebaseDataSource: AuthenticationDataSource
    
    init(authenticationFirebaseDataSource: AuthenticationFirebaseDataSource = AuthenticationFirebaseDataSource()) {
        self.authenticationFirebaseDataSource = authenticationFirebaseDataSource
    }
    
    //Second initializer for test purposes
    init(withDataSource authenticationFirebaseDataSource: AuthenticationDataSource) {
        self.authenticationFirebaseDataSource = authenticationFirebaseDataSource
    }
    
    
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
