//
//  FacebookAuthentication.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 01/04/23.
//

import Foundation

import FacebookLogin

final class FacebookAuthentication {
    let loginManager = LoginManager()
    
    func loginFacebook() async throws -> String {
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                self.loginManager.logIn(permissions: ["email"],
                                   from: nil) { loginManagerLoginResult, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let loginManagerLoginResult = loginManagerLoginResult, let token = loginManagerLoginResult.token {
                        continuation.resume(returning: token.tokenString)
                    }
                }
            }
        }
    }
    
    /*func loginFacebook(completionBlock: @escaping (Result<String, Error>) -> Void) {
        loginManager.logIn(permissions: ["email"],
                           from: nil) { loginManagerLoginResult, error in
            if let error = error {
                print("Error login with Facebook \(error.localizedDescription)")
                completionBlock(.failure(error))
                return
            }
            let token = loginManagerLoginResult?.token?.tokenString
            completionBlock(.success(token ?? "Empty Token Facebook"))
        }
    }*/
    
    func getAccessToken() -> String? {
        AccessToken.current?.tokenString
    }
}
