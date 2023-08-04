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
    
    
    //TODO: maybe this method can be removed
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
    
    func getUser(uid: String, completionBlock: @escaping (Result<User?,Error>) -> Void) {
          let docRef = db.collection("users").document(uid)
        
          docRef.getDocument { document, error in
            if let error = error as NSError? {
                completionBlock(.failure(error))
            }
            else {
                if let document = document, document.exists {
                do {
                print("Document retrieved")
                  let user = try document.data(as: User.self)
                    print("user retrieved \(user)")
                    completionBlock(.success(user))
                }
                catch {
                  print(error)
                }
              }else{
                  completionBlock(.success(nil))
              }
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
            .document(user.id!)
            .setData(user.asDictionary())
    }
    
    /*func modifyUser(uid:String, field: String, value: Any){
        let userRef = db.collection("users").document(uid)
        userRef.updateData([
            field: value
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }*/
    
    func modifyUser(uid: String, field: String, value: String, type : String) {
        let userRef = db.collection("users").document(uid)
        
        switch type {
        case "String":
            userRef.updateData([field: value]) { err in
                self.handleUpdateResult(err: err)
            }
        case "Int":
            userRef.updateData([field: Int(value) ?? 0 ]) { err in
                self.handleUpdateResult(err: err)
            }
        default:
            print("Unsupported data type for value")
        }
    }

    // Helper function to handle the result of the update operation
    func handleUpdateResult(err: Error?) {
        if let err = err {
            print("Error updating document: \(err)")
        } else {
            print("Document successfully updated")
        }
    }

    
    func deleteUserData(uid: String, completionBlock: @escaping (Result<Bool,Error>) -> Void) {
        let reference = Firestore
            .firestore()
            .collection("users")
            .document(uid)
        reference.delete { error in
            if let error = error {
                completionBlock(.failure(error))
            } else {
                completionBlock(.success(true))
            }
        }
    }
}
