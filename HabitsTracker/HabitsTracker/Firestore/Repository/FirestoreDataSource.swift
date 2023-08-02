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
    
    func addNewUser(user: User, completionBlock: @escaping (Result<User, Error>) -> Void) {
        do {
            _ = try db.collection("users").addDocument(from: user)
            completionBlock(.success(user))
        } catch {
            completionBlock(.failure(error))
        }
    }
    
}
