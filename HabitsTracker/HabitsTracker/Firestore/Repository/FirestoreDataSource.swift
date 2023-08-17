import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

import FirebaseAuth
import Combine

final class FirestoreDataSource {
    private let db = Firestore.firestore()
    
    func getCurrentUser() async throws -> User {
        guard let userAuth = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return try await db.collection("users").document(userAuth.uid).getDocument(as: User.self)
    }
    
    // Function that returns true if there exists a document with specific field and value
    func fieldIsPresent(field : String, value: String, completionBlock: @escaping (Result<Bool, Error>) -> Void){
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
    func getFriends(friendsSubcollection: [Friend]) -> AnyPublisher<[User], Error> {
        let requestFriendIDs = friendsSubcollection
            .filter { $0.status == "Confirmed" }
            .map { $0.id }
        
        if !requestFriendIDs.isEmpty {
            let requestedUsersRef = db.collection("users").whereField("id", in: requestFriendIDs)
            
            return Future<[User], Error> { promise in
                requestedUsersRef.getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    var requestedUsers: [User] = []
                    for document in snapshot?.documents ?? [] {
                        if let user = try? document.data(as: User.self) {
                            requestedUsers.append(user)
                        }
                    }
                    
                    promise(.success(requestedUsers))
                }
            }
            .eraseToAnyPublisher()
        } else {
            return Just([]) // Return an empty array
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    // Function that returns the current user's friend requests
    func getRequests(friendsSubcollection: [Friend]) -> AnyPublisher<[User], Error> {
        let requestFriendIDs = friendsSubcollection
            .filter { $0.status == "Request" }
            .map { $0.id }
        
        if !requestFriendIDs.isEmpty {
            let requestedUsersRef = db.collection("users").whereField("id", in: requestFriendIDs)
            
            return Future<[User], Error> { promise in
                requestedUsersRef.getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    var requestedUsers: [User] = []
                    for document in snapshot?.documents ?? [] {
                        if let user = try? document.data(as: User.self) {
                            requestedUsers.append(user)
                        }
                    }
                    
                    promise(.success(requestedUsers))
                }
            }
            .eraseToAnyPublisher()
        } else {
            return Just([]) // Return an empty array
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    // Function that returns all users to whom the current user has sent a friend request
    func getWaitingList(friendsSubcollection: [Friend]) -> AnyPublisher<[User], Error> {
        let requestFriendIDs = friendsSubcollection
            .filter { $0.status == "Waiting" }
            .map { $0.id }
        
        if !requestFriendIDs.isEmpty {
            let requestedUsersRef = db.collection("users").whereField("id", in: requestFriendIDs)
            
            return Future<[User], Error> { promise in
                requestedUsersRef.getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    var requestedUsers: [User] = []
                    for document in snapshot?.documents ?? [] {
                        if let user = try? document.data(as: User.self) {
                            requestedUsers.append(user)
                        }
                    }
                    
                    promise(.success(requestedUsers))
                }
            }
            .eraseToAnyPublisher()
        } else {
            return Just([]) // Return an empty array
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    // Function to add a new user to firestore
    func addNewUser(user: User) { // FIXME: async trows and try await?? not necessary here
        db.collection("users")
            .document(user.id)
            .setData(user.asDictionary(), merge: false)
    }
    
    // Function to update/set a field is a user's document
    func modifyUser(uid: String, field: String, value: Any) {
        let userRef = db.collection("users").document(uid)
    
        userRef.updateData([field: value]) { err in
            self.handleUpdateResult(err: err)
        }
    }
    
    // Overload for arrays of BaseActivity
    func modifyUser(uid: String, field: String, records: [BaseActivity]) {
        let dictionaryRecords = records.map { $0.asDictionary() }

        modifyUser(uid: uid, field: field, value: dictionaryRecords)
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
    func deleteUserData(uid: String) async throws {
        try await db.collection("users")
            .document(uid)
            .delete()
    }
}
