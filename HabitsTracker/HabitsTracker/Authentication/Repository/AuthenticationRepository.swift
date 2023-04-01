//
//  AuthenticationRepository.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 31/03/23.
//

import Foundation

final class AuthenticationRepository {
    private let authenticationFirebaseDataSource: AuthenticationFirebaseDataSource
    
    init(authenticationFirebaseDataSource: AuthenticationFirebaseDataSource = AuthenticationFirebaseDataSource()) {
        self.authenticationFirebaseDataSource = authenticationFirebaseDataSource
    }
    
    func getCurrentUser() -> User? {
        authenticationFirebaseDataSource.getCurrentUser()
    }
    
    func createNewUser(email: String, password: String, completionBlock: @escaping (Result<User, Error>) -> Void) {
        authenticationFirebaseDataSource.createNewUser(email: email,
                                                       password: password,
                                                       completionBlock: completionBlock)
    }
    
    func login(email: String, password: String, completionBlock: @escaping (Result<User, Error>) -> Void) {
        authenticationFirebaseDataSource.login(email: email,
                                                       password: password,
                                                       completionBlock: completionBlock)
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
}