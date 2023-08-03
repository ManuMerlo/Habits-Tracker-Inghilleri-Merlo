//
//  FirestoreDataSource.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 03/04/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirestoreDataSource {
    private let db = Firestore.firestore()
    
    func userIsPresent (uid: String, completionBlock: @escaping (Result<Bool, Error>) -> Void){
        
        
        let docRef = db.collection("users").document(uid)
        
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error checking existing user \(error.localizedDescription)")
                completionBlock(.failure(error))
                return
            }
            if let document = document, document.exists {
                completionBlock(.success(true))
            } else {
                completionBlock(.success(false))
            }
        }
        
    }
    
    func getAllUsers(completionBlock: @escaping (Result<[User], Error>) -> Void) {
        db.collection("users").addSnapshotListener { query, error in
            if let error = error {
                print("Error getting all users \(error.localizedDescription)")
                completionBlock(.failure(error))
                return
            }
            // MARK: If the query success but the array of users is only one element
            // MARK: compactmap $0 remove null alements
            guard let documents = query?.documents.compactMap({ $0 }) else {
                completionBlock(.success([]))
                return
            }
            let users = documents.map { try? $0.data(as: User.self) }.compactMap { $0 }
            completionBlock(.success(users))
        }
    }
    
    
    func addNewUser(user: User) {
        db.collection("users")
            .document(user.id)
            .setData(user.asDictionary())
    }
}
