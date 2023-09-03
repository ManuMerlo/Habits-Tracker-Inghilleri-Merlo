import Foundation
import FirebaseAuth

protocol AuthenticationDataSource {
    func getAuthenticatedUser() throws -> User
    func createNewUser(email: String, password: String) async throws -> User
    func login(email: String, password: String) async throws -> User
    func loginFacebook() async throws -> User
    func loginGoogle() async throws -> User
    func linkGoogle() async throws
    func logout() throws
    func getCurrentProvider() -> [LinkedAccounts]
    func linkFacebook() async throws
    func getCurrentCredential() -> AuthCredential?
    func linkEmailAndPassword(email: String, password: String) async throws
    func deleteUser() async throws
    func resetPassword(email: String) async throws
    func updateEmail(email: String) async throws
    func updatePassword(password: String) async throws
}

final class AuthenticationFirebaseDataSource: AuthenticationDataSource {
    private let facebookAuthentication = FacebookAuthentication()
    private let googleAuthentication = GoogleAuthentication()
    
    func getAuthenticatedUser() throws -> User {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw AuthenticationError.userNotLogged
        }
        return User(id: user.uid, email: email)
    }
    
    func createNewUser(email: String, password: String) async throws -> User {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return User(id: authDataResult.user.uid, email: authDataResult.user.email ?? "")
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotLogged
        }

        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotLogged
        }
        
        try await user.updateEmail(to: email)
    }
    
    
    func login(email: String, password: String) async throws -> User {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return User(id: authDataResult.user.uid, email: authDataResult.user.email ?? "")
    }
    
    func loginFacebook() async throws -> User {
        let accessToken = try await facebookAuthentication.loginFacebook()
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        let authDataResult: AuthDataResult = try await Auth.auth().signIn(with: credential)
        return User(id: authDataResult.user.uid, email: authDataResult.user.email ?? "")
    }
    
    func loginGoogle() async throws -> User {
        let user = try await googleAuthentication.loginGoogle()
        let idToken = user.authentication.idToken ?? "No idToken"
        let accessToken = user.authentication.accessToken
        let credential: AuthCredential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let authDataResult: AuthDataResult = try await Auth.auth().signIn(with: credential)
        return User(id: authDataResult.user.uid, email: authDataResult.user.email ?? "")
    }
    
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
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentProvider() -> [LinkedAccounts] {
        guard let currentUser = Auth.auth().currentUser else {
            return []
        }
        let linkedAccounts = currentUser.providerData.map{ userInfo in
            LinkedAccounts(rawValue: userInfo.providerID)
        }.compactMap{ $0 }
        return linkedAccounts
    }
    
    func linkFacebook() async throws {
        guard let userAuth = Auth.auth().currentUser else {
            throw AuthenticationError.userNotLogged
        }
        let accessToken = try await facebookAuthentication.loginFacebook()
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        try await userAuth.link(with: credential)
    }
    
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
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotLogged
        }
        try await user.delete()
    }
}

