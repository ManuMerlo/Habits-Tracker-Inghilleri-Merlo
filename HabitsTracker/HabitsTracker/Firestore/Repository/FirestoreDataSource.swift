//
//  FirestoreDataSource.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 03/04/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

final class FirestoreDataSource {
    private let db = Firestore.firestore()
    
    //Function that returns the current user
    func getCurrentUser(completionBlock: @escaping (Result<User,Error>) -> Void) {
        if let userAuth = Auth.auth().currentUser {
            let docRef = db.collection("users").document(userAuth.uid)
            docRef.addSnapshotListener { documentSnapshot, error in
                if let error = error as NSError? {
                    completionBlock(.failure(error))
                } else if let document = documentSnapshot, document.exists {
                    do {
                        print("Document retrieved")
                        let user = try document.data(as: User.self)
                        
                        if userAuth.uid == user.id {
                            print("user Auth id: \(userAuth.uid)")
                            print("user retrieved \(user)")
                            completionBlock(.success(user))
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    // Function that returns true if there exists a document with specific field and value
    func fieldIsPresent (field : String, value: String, completionBlock: @escaping (Result<Bool, Error>) -> Void){
        let usersCollection = db.collection("users")
        
        // Perform the query to get the document with username "name"
        usersCollection.whereField(field, isEqualTo: value).getDocuments { (querySnapshot, error) in
            if let error = error {
                completionBlock(.failure(error))
                print("Error fetching document: \(error)")
                return
            }
            
            // Check if there are any matching documents
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                completionBlock(.success(false))
                return
            }
            
            completionBlock(.success(true))
            
            // Assuming there's only one matching document, you can access it like this
            let document = documents[0]
            let data = document.data()
            // Now you can access the fields of the document, for example:
            if let retrievedValue = data[field] as? String {
                print("Found document with \(field): \(retrievedValue)")
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
    
    // Function that returns all the docouments in the current user's subcollection "friends"
    func getFriendsSubcollection(completionBlock: @escaping([Friend]?) -> Void) {
        if let userAuth = Auth.auth().currentUser {
            let friendsRef = self.db.collection("users").document(userAuth.uid).collection("friends")
            friendsRef.addSnapshotListener{ querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching friend documents: \(error!)")
                    return
                }
                var updatedFriends: [Friend] = []
                for document in documents {
                    if let friendStatus = document.data()["status"] as? String {
                        let friendID = document.documentID
                        let friend = Friend(id: friendID, status: friendStatus) // Assuming Friend is a custom struct or class
                        updatedFriends.append(friend)
                    }
                }
                completionBlock(updatedFriends)
            }
        }
    }
    
    // Function that returns the current user's friends
    func getFriends(friendsSubcollection:[Friend], completionBlock: @escaping([User]?) -> Void){
        let requestFriendIDs = friendsSubcollection
            .filter { $0.status == "Confirmed" }
            .map { $0.id }
        if !requestFriendIDs.isEmpty{
            let requestedUsersRef = self.db.collection("users").whereField("id", in: requestFriendIDs)
            requestedUsersRef.getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching requested user documents: \(error!)")
                    completionBlock([])
                    return
                }
                
                var requestedUsers: [User] = []
                for document in documents {
                    if let user = try? document.data(as: User.self) {
                        requestedUsers.append(user)
                    }
                }
                
                completionBlock(requestedUsers)
            }
            
        } else {
            completionBlock([])
        }
    }
    
    // Function that returns the current user's friend requests
    func getRequests(friendsSubcollection:[Friend],completionBlock: @escaping ([User]?) -> Void){
        let requestFriendIDs = friendsSubcollection
            .filter { $0.status == "Request"}
            .map { $0.id }
        
        if !requestFriendIDs.isEmpty{
            let requestedUsersRef = self.db.collection("users").whereField("id", in:  requestFriendIDs)
            requestedUsersRef.getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching requested user documents: \(error!)")
                    completionBlock([])
                    return
                }
                
                var requestedUsers: [User] = []
                for document in documents {
                    if let user = try? document.data(as: User.self) {
                        requestedUsers.append(user)
                    }
                }
                
                completionBlock(requestedUsers)
            }
            
        } else {
            completionBlock([])
        }
    }
    
    // Function that returns all users to whom the current user has sent a friend request
    func getWaitingList(friendsSubcollection:[Friend],completionBlock: @escaping ([User]?) -> Void){
        let requestFriendIDs = friendsSubcollection
            .filter { $0.status == "Waiting" }
            .map { $0.id }
        if !requestFriendIDs.isEmpty{
            let requestedUsersRef = self.db.collection("users").whereField("id", in:  requestFriendIDs)
            requestedUsersRef.getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching requested user documents: \(error!)")
                    completionBlock([])
                    return
                }
                
                var requestedUsers: [User] = []
                for document in documents {
                    if let user = try? document.data(as: User.self) {
                        requestedUsers.append(user)
                    }
                }
                
                completionBlock(requestedUsers)
            }
            
        } else {
            completionBlock([])
        }
    }
    
    // Function to add a new user to firestore
    func addNewUser(user: User) {
        db.collection("users")
            .document(user.id!)
            .setData(user.asDictionary())
    }
    
    // Function to update/set a filed is a user's document
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
    
    // Function to add a single friend to the 'friends' array for a user in Firestore
    func addRequest(uid: String, friend : String) {
        let batch = db.batch()
        
        // Create a document for the current user's friend
        let currentUserFriendRef = db.collection("users").document(uid).collection("friends").document(friend)
        batch.setData(["status": "Waiting"], forDocument: currentUserFriendRef)
        
        // Create a document for the friend as well
        let friendFriendRef = db.collection("users").document(friend).collection("friends").document(uid)
        batch.setData(["status": "Request"], forDocument: friendFriendRef)
        
        batch.commit { error in
            if let error = error {
                print("Batch write failed: \(error)")
            } else {
                print("Batch write successful!")
            }
        }
    }
    
    // Function to remove a friend from the 'friends' collection
    func removeFriend(uid: String, friend: String) {
        let batch = db.batch()
        
        let userRef = db.collection("users").document(uid).collection("friends").document(friend)
        let friendRef = db.collection("users").document(friend).collection("friends").document(uid)
        
        batch.deleteDocument(userRef)
        batch.deleteDocument(friendRef)
        
        batch.commit { error in
            if let error = error {
                print("Batch write failed: \(error)")
            } else {
                print("Batch write succeeded!")
            }
        }
    }
    
    // Function to update documents and confirm a relationship
    func confirmFriend(uid: String, friendId: String) {
        let batch = db.batch()
        
        let userRef = db.collection("users").document(uid).collection("friends").document(friendId)
        let friendRef = db.collection("users").document(friendId).collection("friends").document(uid)
        
        batch.updateData(["status": "Confirmed"], forDocument: userRef)
        batch.updateData(["status": "Confirmed"], forDocument: friendRef)
        
        batch.commit { error in
            if let error = error {
                print("Batch write failed: \(error)")
            } else {
                print("Batch write successful!")
            }
        }
    }
    
    // Function to update/set an array in a user's document
    func updateDailyScores(uid: String, newScore: Int) {
        let userRef = db.collection("users").document(uid)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                var scoresArray = document.get("dailyScores") as? [Int] ?? []
                
                let today = (Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
                
                scoresArray[today] = newScore
                
                let scoresInRange = scoresArray[0...today]
                    
                scoresArray[7] = scoresInRange.reduce(0, +)
                
                userRef.updateData(["dailyScores": scoresArray]) { err in
                    self.handleUpdateResult(err: err)
                }
            }
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
    
    // Fuction to delete user's document in firestore
    func deleteUserData(uid: String, completionBlock: @escaping (Result<Bool,Error>) -> Void) {
        db.collection("users")
            .document(uid)
            .delete { error in
                if let error = error {
                    completionBlock(.failure(error))
                } else {
                    completionBlock(.success(true))
                }
            }
    }
}
