//
//  GoogleAuthentication.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 01/04/23.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

final class GoogleAuthentication {
    func loginGoogle(completionBlock: @escaping (Result<GIDGoogleUser?, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No clientID found in Firebase Configuration")
        }
        GIDSignIn.sharedInstance.signIn(with: .init(clientID: clientID), presenting: UIApplication.shared.rootController()) { user, error in
            if let error = error {
                print("Error login with Google \(error.localizedDescription)")
                completionBlock(.failure(error))
                return
            }
            completionBlock(.success(user ?? nil))
        }
    }
}
