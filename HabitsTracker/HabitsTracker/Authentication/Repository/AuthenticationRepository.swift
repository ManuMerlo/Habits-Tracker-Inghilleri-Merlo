final class AuthenticationRepository {
    private let authenticationFirebaseDataSource: AuthenticationFirebaseDataSource
    
    init(authenticationFirebaseDataSource: AuthenticationFirebaseDataSource = AuthenticationFirebaseDataSource()) {
        self.authenticationFirebaseDataSource = authenticationFirebaseDataSource
    }
    
    func getAuthenticatedUser() throws -> User {
        return try authenticationFirebaseDataSource.getAuthenticatedUser()
    }
    
    func createNewUser(email: String, password: String) async throws -> User {
        return try await authenticationFirebaseDataSource.createNewUser(email: email, password: password)
    }
    
    func login(email: String, password: String) async throws -> User {
        return try await authenticationFirebaseDataSource.login(email: email, password: password)
    }
    
    func loginFacebook(completionBlock: @escaping (Result<User, Error>) -> Void) {
        authenticationFirebaseDataSource.loginFacebook(completionBlock: completionBlock)
    }
    
    func loginGoogle(completionBlock: @escaping (Result<User, Error>) -> Void) {
        authenticationFirebaseDataSource.loginGoogle(completionBlock: completionBlock)
    }
    
    func logout() throws {
        try authenticationFirebaseDataSource.logout()
    }
    
    func getCurrentProvider() -> [LinkedAccounts] {
        authenticationFirebaseDataSource.getCurrentProvider()
    }
    
    func linkFacebook(completionBlock: @escaping (Bool) -> Void) {
        authenticationFirebaseDataSource.linkFacebook(completionBlock: completionBlock)
    }
    
    func linkGoogle(completionBlock: @escaping (Bool) -> Void) {
        authenticationFirebaseDataSource.linkGoogle(completionBlock: completionBlock)
    }
    
    func linkEmailAndPassword(email:String ,password:String,completionBlock: @escaping (Bool) -> Void){
        authenticationFirebaseDataSource.linkEmailAndPassword(email:email,
                                                              password: password,
                                                              completionBlock: completionBlock)
    }
    
    /*func deleteUser(completionBlock: @escaping (Result<Bool,Error>) -> Void) {
        authenticationFirebaseDataSource.deleteUser(completionBlock: completionBlock)
    }*/
    func deleteUser() async throws {
        try await authenticationFirebaseDataSource.deleteUser()
    }
}
