import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

// MARK: - FirestoreDataSource

/// The concrete implementation of the FirestoreDataSourceProtocol.
/// Handles all CRUD operations, listener methods, and specific logic for users and friends in Firestore.
final class FirestoreDataSource : FirestoreDataSourceProtocol {
    private let db = Firestore.firestore()
    private var currentUserListener: ListenerRegistration? = nil
    private var friendsSubcollectionListener: ListenerRegistration? = nil
    
    /// Adds a listener for changes to the current user's data in Firestore.
    /// Whenever the user's document changes, the completionBlock is called with the updated data.
    /// - Parameter completionBlock: Closure to handle the fetched User data.
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
    
    /// Removes the listener attached to the current user's data.
    func removeListenerForCurrentUser() {
        self.currentUserListener?.remove()
    }
    
    /// Adds a listener for changes in the current user's friends subcollection in Firestore.
    /// Whenever a friend is added, removed, or changed in the friends subcollection, the completionBlock is called.
    /// - Parameter completionBlock: Closure to handle the fetched array of Friend data.
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
    
    /// Removes the listener attached to the current user's friends subcollection.
    func removeListenerForFriendsSubcollection() {
        self.friendsSubcollectionListener?.remove()
    }
    
    /// Check if a specific field-value pair exists in the 'users' collection.
    /// This can be useful, for example, to check if a user with a certain email already exists.
    /// - Parameters:
    ///   - field: The name of the field.
    ///   - value: The value to check against.
    func fieldIsPresent(field: String, value: String) async throws -> Bool {
        let usersCollection = db.collection("users")
        let snapshot = try await usersCollection.whereField(field, isEqualTo: value).getDocuments()
        guard !(snapshot.documents.isEmpty) else {
            return false
        }
        return true
    }
    
    /// Retrieves a list of User objects based on provided friend request IDs.
    /// This is typically used to fetch the details of users who have sent a friend request to the current user.
    /// - Parameter requestFriendsIDs: An array of user IDs who have sent friend requests.
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
    
    /// Adds a new user to the 'users' collection in Firestore.
    /// - Parameter user: The User object to be added.
    func addNewUser(user: User) {
        db.collection("users")
            .document(user.id)
            .setData(user.asDictionary(), merge: false)
    }
    
    /// Modifies a user document in Firestore by updating a specific field with a new value.
    /// - Parameters:
    ///   - uid: The ID of the user.
    ///   - field: The name of the field to be modified.
    ///   - value: The new value to be set for the field.
    func modifyUser(uid: String, field: String, value: Any) async throws {
        let userRef = db.collection("users").document(uid)
        try await userRef.updateData([field: value])
    }
    
    /// An overloaded version of `modifyUser` specifically for updating an array of `BaseActivity` objects in a user's document.
    /// - Parameters:
    ///   - uid: The ID of the user.
    ///   - field: The name of the field to be modified.
    ///   - newScores: The new array of BaseActivity objects.
    func modifyUser(uid: String, field: String, newScores: [BaseActivity]) async throws {
        let dictionaryRecords = newScores.map { $0.asDictionary() }
        try await modifyUser(uid: uid, field: field, value: dictionaryRecords)
    }
    
    /// Adds a friend request to both the current user's and the friend's 'friends' subcollections in Firestore.
    /// - Parameters:
    ///   - uid: The ID of the user sending the request.
    ///   - friendId: The ID of the user receiving the request.
    func addRequest(uid: String, friendId: String) async throws {
        let batch = db.batch()
        let currentUserFriendRef = db.collection("users").document(uid).collection("friends").document(friendId)
        batch.setData(["id": friendId, "status": FriendStatus.Waiting.rawValue], forDocument: currentUserFriendRef)
        let friendFriendRef = db.collection("users").document(friendId).collection("friends").document(uid)
        batch.setData(["id": uid, "status": FriendStatus.Request.rawValue], forDocument: friendFriendRef)
        
        try await batch.commit()
    }
    
    /// Removes a friend from both the current user's and the friend's 'friends' subcollections in Firestore.
    /// - Parameters:
    ///   - uid: The ID of one of the users.
    ///   - friendId: The ID of the other user.
    func removeFriend(uid: String, friendId: String) async throws {
        let batch = db.batch()
        let userRef = db.collection("users").document(uid).collection("friends").document(friendId)
        let friendRef = db.collection("users").document(friendId).collection("friends").document(uid)
        batch.deleteDocument(userRef)
        batch.deleteDocument(friendRef)
        try await batch.commit()
    }
    
    /// Confirms a friend request in Firestore by updating the friend status in both users' 'friends' subcollections.
    /// - Parameters:
    ///   - uid: The ID of the user confirming the request.
    ///   - friendId: The ID of the user who sent the request.
    func confirmFriend(uid: String, friendId: String) async throws {
        let batch = db.batch()
        let userRef = db.collection("users").document(uid).collection("friends").document(friendId)
        let friendRef = db.collection("users").document(friendId).collection("friends").document(uid)
        batch.updateData(["status": FriendStatus.Confirmed.rawValue], forDocument: userRef)
        batch.updateData(["status": FriendStatus.Confirmed.rawValue], forDocument: friendRef)
        try await batch.commit()
    }
    
    /// Updates a user's daily scores in Firestore.
    /// This method first retrieves the user's current scores, modifies the score for the current day, and then updates the array in Firestore.
    /// - Parameters:
    ///   - uid: The ID of the user.
    ///   - newScore: The new score to be added for the day.
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
    
    /// Deletes a user's document from the 'users' collection in Firestore.
    /// - Parameter uid: The ID of the user to be deleted.
    func deleteUserData(uid: String) async throws {
        try await db.collection("users")
            .document(uid)
            .delete()
    }
    
    /// A utility method to handle the result of Firestore update operations and print relevant messages.
    /// - Parameter err: The error, if any, from the update operation.
    func handleUpdateResult(err: Error?) {
        if let err = err {
            print("Error updating document: \(err)")
        } else {
            print("Document successfully updated")
        }
    }
}
