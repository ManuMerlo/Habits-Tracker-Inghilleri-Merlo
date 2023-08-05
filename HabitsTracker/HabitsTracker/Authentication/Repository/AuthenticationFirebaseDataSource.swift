//
//  AuthenticationFirebaseDataSource.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 31/03/23.
//

import Foundation
import FirebaseAuth

final class AuthenticationFirebaseDataSource {
    private let facebookAuthentication = FacebookAuthentication()
    private let googleAuthentication = GoogleAuthentication()
    
    func getCurrentUser() -> User? {
        guard let email = Auth.auth().currentUser?.email else {
            return nil
        }
        guard let id = Auth.auth().currentUser?.uid else {
            return nil
        }
        return .init(id: id, email: email)
    }
    
    // MARK: Completionblock: Notify the upper layers: Repository, ViewModel and the to View. Indicate if there will be an error or not during the creation of a new user. the @escaping returns a user if there is not error, otherwise it returns an error.
    func createNewUser(email: String, password: String, completionBlock: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            if let error = error {
                print("Error creating a new user \(error.localizedDescription)")
                completionBlock(.failure(error))
                return
            }
            let email = authDataResult?.user.email ?? "No email"
            let id = authDataResult?.user.uid ?? "No id"
            print("New user created with info \(email) \(id)")
            completionBlock(.success(.init(id:id ,email: email)))
        }
    }
    
    
    //TODO: Se l'id è gia presente negli user non fare niente altrimenti crea lo user
    
    func login(email: String, password: String, completionBlock: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if let error = error {
                print("Error login user \(error.localizedDescription)")
                completionBlock(.failure(error))
                return
            }
            
            let email = authDataResult?.user.email ?? "No email"
            let id = authDataResult?.user.uid ?? "No id"
            print("User logged in with info \(email) \(id)")
            completionBlock(.success(.init(id: id,email: email)))
        }
    }
    
    func loginFacebook(completionBlock: @escaping (Result<User, Error>) -> Void) {
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
    }
    
    func loginGoogle(completionBlock: @escaping (Result<User, Error>) -> Void) {
        googleAuthentication.loginGoogle { result in
            switch result {
            case .success(let user):
                let idToken = user?.authentication.idToken ?? "No idToken"
                let accessToken = user?.authentication.accessToken ?? "No accessToken"
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                Auth.auth().signIn(with: credential) { authDataResult, error in
                    if let error = error {
                        print("Error creating a new user \(error.localizedDescription)")
                        completionBlock(.failure(error))
                        return
                    }
                    let email = authDataResult?.user.email ?? "No email google"
                    let id = authDataResult?.user.uid ?? "No id google "
                    print("New user 'created' with info \(email) \(id)")
                    completionBlock(.success(.init(id:id ,email: email)))
                }
            case .failure(let error):
                print("Error login with Google \(error.localizedDescription)")
                completionBlock(.failure(error))
            }
        }
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentProvider() -> [LinkedAccounts]{
        // We could use getCurrentUser
        guard let currentUser = Auth.auth().currentUser else{
            return []
        }
        let linkedAccounts = currentUser.providerData.map{ userInfo in
            LinkedAccounts(rawValue: userInfo.providerID)
        }.compactMap{$0}
        return linkedAccounts
    }
    
    func linkFacebook(completionBlock: @escaping (Bool) -> Void){
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
    }
    
    func linkGoogle(completionBlock: @escaping (Bool) -> Void){
        googleAuthentication.loginGoogle { result in
            switch result {
            case .success(let user):
                let idToken = user?.authentication.idToken ?? "No idToken"
                let accessToken = user?.authentication.accessToken ?? "No accessToken"
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                Auth.auth().currentUser?.link(with: credential, completion: { authDataResult, error in
                    if let error = error {
                        print("Error linking a new user \(error.localizedDescription)")
                        completionBlock(false)
                        return
                    }
                    let email = authDataResult?.user.email ?? "No email google"
                    print("New user linked with info \(email)")
                    completionBlock(true)
                })
            case .failure(let error):
                print("Error linking with Google \(error.localizedDescription)")
                completionBlock(false)
            }
        }
    }
    
    func getCurrentCredential() -> AuthCredential? {
        guard let providerId = getCurrentProvider().last else {
            return nil
        }
        
        switch providerId{
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
    
    func linkEmailAndPassword(email:String ,password:String,completionBlock: @escaping (Bool) -> Void){
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
    
    func deleteUser(completionBlock: @escaping (Result<Bool,Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                if let error = error {
                    completionBlock(.failure(error))
                } else {
                    completionBlock(.success(true))
                }
            }
        }
    }

    
}

