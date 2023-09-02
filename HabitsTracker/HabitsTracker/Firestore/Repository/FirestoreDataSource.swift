import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

protocol FirestoreDataSourceProtocol {
    
    // Listeners
    func addListenerForCurrentUser(completionBlock: @escaping (Result<User, Error>) -> Void)
    func removeListenerForCurrentUser()
    func addListenerForFriendsSubcollection(completionBlock: @escaping([Friend]) -> Void)
    func removeListenerForFriendsSubcollection()
    
    // CRUD for User
    func addNewUser(user: User)
    func modifyUser(uid: String, field: String, value: Any) async throws
    func modifyUser(uid: String, field: String, newScores: [BaseActivity]) async throws
    func deleteUserData(uid: String) async throws
    
    // User operations
    func updateDailyScores(uid: String, newScore: Int) async throws
    func fieldIsPresent(field: String, value: String) async throws -> Bool
    
    // Friend Operations
    func addRequest(uid: String, friendId: String) async throws
    func removeFriend(uid: String, friendId: String) async throws
    func confirmFriend(uid: String, friendId: String) async throws
    func getRequests(requestFriendsIDs: [String]) async throws -> [User]
    
    // Helper
    func handleUpdateResult(err: Error?)
}


final class FirestoreDataSource : FirestoreDataSourceProtocol {
    private let db = Firestore.firestore()
    private var currentUserListener: ListenerRegistration? = nil
    private var friendsSubcollectionListener: ListenerRegistration? = nil
    
    func addListenerForCurrentUser(completionBlock: @escaping (Result<User,Error>) -> Void) {
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
                        completionBlock(.failure(error))
                    }
                }
            }
        }
    }
    
    func removeListenerForCurrentUser() {
        self.currentUserListener?.remove()
    }
    
    // Function that returns true if there exists a document with specific field and value
    func fieldIsPresent(field: String, value: String) async throws -> Bool {
        let usersCollection = db.collection("users")
        let snapshot = try await usersCollection.whereField(field, isEqualTo: value).getDocuments()
        guard !(snapshot.documents.isEmpty) else {
            return false
        }
        return true
    }
    
    // Function that returns all the docouments in the current user's subcollection "friends"
    func addListenerForFriendsSubcollection(completionBlock: @escaping([Friend]) -> Void) {
        if let userAuth = Auth.auth().currentUser {
            let friendsRef = self.db.collection("users").document(userAuth.uid).collection("friends")
            self.friendsSubcollectionListener = friendsRef.addSnapshotListener{ querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching friend documents: \(error!)")
                    return
                }
                var updatedFriends: [Friend] = []
                for document in documents {
                    do {
                        let friend = try document.data(as: Friend.self)
                        updatedFriends.append(friend)
                    } catch {
                        print("Friend not found")
                    }
                }
                completionBlock(updatedFriends)
            }
        }
    }
    
    func removeListenerForFriendsSubcollection() {
        self.friendsSubcollectionListener?.remove()
    }
    
    // Function that returns the current user's friend requests
    func getRequests(requestFriendsIDs: [String]) async throws -> [User] {
        guard !requestFriendsIDs.isEmpty else {
            return []
        }
        var requestUsers: [User] = []
        let snapshot = try await db.collection("users").whereField("id", in: requestFriendsIDs).getDocuments()
        for document in snapshot.documents {
            let user = try document.data(as: User.self)
            requestUsers.append(user)
        }
        return requestUsers
    }
    
    // Function to add a new user to firestore
    func addNewUser(user: User) { 
        db.collection("users")
            .document(user.id)
            .setData(user.asDictionary(), merge: false)
    }
    
    // Function to update/set a field is a user's document
    func modifyUser(uid: String, field: String, value: Any) async throws {
        let userRef = db.collection("users").document(uid)
        try await userRef.updateData([field: value])
    }
    
    // Overload for arrays of BaseActivity
    func modifyUser(uid: String, field: String, newScores: [BaseActivity]) async throws {
        let dictionaryRecords = newScores.map { $0.asDictionary() }
        try await modifyUser(uid: uid, field: field, value: dictionaryRecords)
    }

    // Function to add a single friend to the 'friends' subcollection for a user in Firestore
    func addRequest(uid: String, friendId: String) async throws {
        let batch = db.batch()
        
        // Create a document for the current user's friend
        let currentUserFriendRef = db.collection("users").document(uid).collection("friends").document(friendId)
        batch.setData(["id": friendId, "status": FriendStatus.Waiting.rawValue], forDocument: currentUserFriendRef)
        
        // Create a document for the friend as well
        let friendFriendRef = db.collection("users").document(friendId).collection("friends").document(uid)
        batch.setData(["id": uid, "status": FriendStatus.Request.rawValue], forDocument: friendFriendRef)
        
        try await batch.commit()
    }
    
    // Function to remove a friend from the 'friends' collection
    func removeFriend(uid: String, friendId: String) async throws {
        let batch = db.batch()
        
        let userRef = db.collection("users").document(uid).collection("friends").document(friendId)
        let friendRef = db.collection("users").document(friendId).collection("friends").document(uid)
        
        batch.deleteDocument(userRef)
        batch.deleteDocument(friendRef)
        
        try await batch.commit()
    }
    
    // Function to update documents and confirm a relationship
    func confirmFriend(uid: String, friendId: String) async throws {
        let batch = db.batch()
        
        let userRef = db.collection("users").document(uid).collection("friends").document(friendId)
        let friendRef = db.collection("users").document(friendId).collection("friends").document(uid)
        
        batch.updateData(["status": FriendStatus.Confirmed.rawValue], forDocument: userRef)
        batch.updateData(["status": FriendStatus.Confirmed.rawValue], forDocument: friendRef)
        
        try await batch.commit()
    }
    
    // Function to update/set an array in a user's document
    func updateDailyScores(uid: String, newScore: Int) async throws {
        let userRef = db.collection("users").document(uid)
        let userSnapshot = try await userRef.getDocument(as: User.self)
        var scoresArray: [Int] = userSnapshot.dailyScores
        let today = (Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
        scoresArray[today] = newScore
        let scoresInRange = scoresArray[0...today]
        scoresArray[7] = scoresInRange.reduce(0, +)
        try await userRef.updateData(["dailyScores": scoresArray])
    }
    
    // Fuction to delete user's document in firestore
    func deleteUserData(uid: String) async throws {
        try await db.collection("users")
            .document(uid)
            .delete()
    }
    
    // Helper function to handle the result of the update operation
    func handleUpdateResult(err: Error?) {
        if let err = err {
            print("Error updating document: \(err)")
        } else {
            print("Document successfully updated")
        }
    }
}
