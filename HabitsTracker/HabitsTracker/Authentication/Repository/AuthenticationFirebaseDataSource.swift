import Foundation
import FirebaseAuth

final class AuthenticationFirebaseDataSource {
    private let facebookAuthentication = FacebookAuthentication()
    private let googleAuthentication = GoogleAuthentication()
    
    func getAuthenticatedUser() throws -> User {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw URLError(.badServerResponse) // Customize error
        }
        return User(id: user.uid, email: email)
    }
    
    func createNewUser(email: String, password: String) async throws -> User {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        //FIXME: if email is nil
        return User(id: authDataResult.user.uid, email: authDataResult.user.email ?? "")
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updateEmail(to: email)
    }
    
    
    func login(email: String, password: String) async throws -> User {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        //FIXME: if email is nil
        return User(id: authDataResult.user.uid, email: authDataResult.user.email ?? "")
    }
    
    func loginFacebook() async throws -> User {
        let accessToken = try await facebookAuthentication.loginFacebook()
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        let authDataResult: AuthDataResult = try await Auth.auth().signIn(with: credential)
        //FIXME: if email is nil
        return User(id: authDataResult.user.uid, email: authDataResult.user.email ?? "")
    }
    
    /*func loginFacebook(completionBlock: @escaping (Result<User, Error>) -> Void) {
     facebookAuthentication.loginFacebook { result in
     switch result {
     case .success(let accessToken):
     let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
     Auth.auth().signIn(with: credential) { authDataResult, error in
     if let error = error {
     print("Error creating a new user \(error.localizedDescription)")
     completionBlock(.failure(error))
     return
     }
     let email = authDataResult?.user.email ?? "No email facebook"
     let id = authDataResult?.user.uid ?? "No id facebook"
     print("New user 'created' with info \(email) \(id)")
     completionBlock(.success(.init(id:id, email: email)))
     }
     case .failure(let error):
     print("Error login with Facebook \(error.localizedDescription)")
     completionBlock(.failure(error))
     }
     }
     }*/
    
    func loginGoogle() async throws -> User {
        let user = try await googleAuthentication.loginGoogle()
        let idToken = user.authentication.idToken ?? "No idToken"
        let accessToken = user.authentication.accessToken
        let credential: AuthCredential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let authDataResult: AuthDataResult = try await Auth.auth().signIn(with: credential)
        //FIXME: if email is nil
        return User(id: authDataResult.user.uid, email: authDataResult.user.email ?? "")
    }
    
    func linkGoogle() async throws {
        guard let userAuth = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
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
            throw URLError(.badServerResponse)
        }
        let accessToken = try await facebookAuthentication.loginFacebook()
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        try await userAuth.link(with: credential)
    }
    
    /*func linkFacebook(completionBlock: @escaping (Bool) -> Void) {
     facebookAuthentication.loginFacebook { result in
     switch result {
     case .success(let accessToken):
     let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
     Auth.auth().currentUser?.link(with: credential, completion: { authDataResult, error in
     if let error = error {
     print("Error linking new user \(error.localizedDescription)")
     completionBlock(false)
     return
     }
     let email = authDataResult?.user.email ?? "No email facebook"
     print("New user linked with info \(email)")
     completionBlock(true)
     })
     case .failure(let error):
     print("Error linking a new user with Facebook \(error.localizedDescription)")
     completionBlock(false)
     }
     }
     }*/
    
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
    
    func linkEmailAndPassword(email:String, password:String, completionBlock: @escaping (Bool) -> Void){
        guard let credential = getCurrentCredential() else {
            print("Error creating credential")
            completionBlock(false)
            return
        }
        Auth.auth().currentUser?.reauthenticate(with: credential,completion: { authDataResult, error in
            if let error = error{
                print("Error reauthenticating a user \(error.localizedDescription)")
                completionBlock(false)
                return
            }
            
            let emailAndPasswordCredential = EmailAuthProvider.credential(withEmail: email, password: password)
            Auth.auth().currentUser?.link(with: emailAndPasswordCredential, completion: { authDataResult, error in
                if let error = error {
                    print("Error linking new user \(error.localizedDescription)")
                    completionBlock(false)
                    return
                }
                let email = authDataResult?.user.email ?? "No email"
                print("New user linked with info \(email)")
                completionBlock(true)
            })
            
        })
    }
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
    }
}

