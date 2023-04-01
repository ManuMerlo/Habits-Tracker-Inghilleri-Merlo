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
        return .init(email: email)
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
            print("New user created with info \(email)")
            completionBlock(.success(.init(email: email)))
        }
    }
    
    func login(email: String, password: String, completionBlock: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if let error = error {
                print("Error login user \(error.localizedDescription)")
                completionBlock(.failure(error))
                return
            }
            
            let email = authDataResult?.user.email ?? "No email"
            print("User logged in with info \(email)")
            completionBlock(.success(.init(email: email)))
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
                    print("New user 'created' with info \(email)")
                    completionBlock(.success(.init(email: email)))
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
                    print("New user 'created' with info \(email)")
                    completionBlock(.success(.init(email: email)))
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
    
}
