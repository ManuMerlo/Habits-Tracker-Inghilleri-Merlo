import Foundation
import UIKit

/// `FirestoreRepository` is a high-level class that abstracts the interactions with the Firestore database.
/// It utilizes a data source to perform the CRUD (Create, Read, Update, Delete) operations and other Firebase interactions.
final class FirestoreRepository {
    private let firestoreDataSource: FirestoreDataSourceProtocol
    
    /// Default initializer that uses the `FirestoreDataSource` as the data source.
    /// - Parameter firestoreDataSource: An instance of `FirestoreDataSource`. Default value is `FirestoreDataSource()`.
    init(firestoreDataSource: FirestoreDataSource = FirestoreDataSource()) {
        self.firestoreDataSource = firestoreDataSource
    }
    
    /// Secondary initializer for test purposes.
    /// It allows the injection of mock data sources or other custom data sources conforming to `FirestoreDataSourceProtocol`.
    /// - Parameter firestoreDataSource: A custom data source conforming to `FirestoreDataSourceProtocol`.
    init(withDataSource firestoreDataSource: FirestoreDataSourceProtocol) {
        self.firestoreDataSource = firestoreDataSource
    }
    
    /// Adds a listener for changes to the current user's data in Firestore.
    /// - Parameter completionBlock: Closure to handle the fetched `User` data or potential errors.
    func addListenerForCurrentUser(completionBlock: @escaping (Result<User, Error>) -> Void) {
        firestoreDataSource.addListenerForCurrentUser(completionBlock: completionBlock)
    }
    
    /// Removes the listener attached to the current user's data.
    func removeListenerForCurrentUser() {
        firestoreDataSource.removeListenerForCurrentUser()
    }
    
    /// Adds a listener for changes in the current user's friends subcollection in Firestore.
    /// - Parameter completionBlock: Closure to handle the fetched array of `Friend` data.
    func addListenerForFriendsSubcollection(completionBlock: @escaping([Friend]) -> Void) {
        firestoreDataSource.addListenerForFriendsSubcollection(completionBlock: completionBlock)
    }
    
    /// Removes the listener attached to the current user's friends subcollection.
    func removeListenerForFriendsSubcollection() {
        firestoreDataSource.removeListenerForFriendsSubcollection()
    }
    
    /// Checks if a specific field-value pair exists in the 'users' collection.
    /// - Parameters:
    ///   - field: The name of the field.
    ///   - value: The value to check against.
    /// - Returns: Boolean indicating if the field-value pair exists.
    func fieldIsPresent (field: String, value: String) async throws -> Bool {
        return try await firestoreDataSource.fieldIsPresent(field: field, value:value)
    }
    
    /// Adds a new user to Firestore.
    /// - Parameter user: The `User` object to be added.
    func addNewUser(user: User) {
        firestoreDataSource.addNewUser(user: user)
    }
    
    /// Retrieves a list of `User` objects based on provided friend request IDs.
    /// - Parameter requestFriendsIDs: An array of user IDs who have sent friend requests.
    /// - Returns: Array of `User` objects.
    func getRequests(requestFriendsIDs: [String]) async throws -> [User] {
        return try await firestoreDataSource.getRequests(requestFriendsIDs: requestFriendsIDs)
    }
    
    /// Modifies a user document in Firestore by updating a specific field with a new value.
    /// - Parameters:
    ///   - uid: The ID of the user.
    ///   - field: The name of the field to be modified.
    ///   - value: The new value to be set for the field.
    func modifyUser(uid:String, field: String, value: Any) async throws {
        try await firestoreDataSource.modifyUser(uid:uid, field: field, value: value)
    }
    
    /// Modifies a user document in Firestore by updating a specific field with an array of `BaseActivity` objects.
    /// - Parameters:
    ///   - uid: The ID of the user.
    ///   - field: The name of the field to be modified.
    ///   - newScores: The new array of `BaseActivity` objects.
    func modifyUser(uid: String, field: String, newScores: [BaseActivity]) async throws {
        try await firestoreDataSource.modifyUser(uid: uid, field: field, newScores: newScores)
    }
    
    /// Sends a friend request by updating both the current user's and the friend's 'friends' subcollections in Firestore.
    /// - Parameters:
    ///   - uid: The ID of the user sending the request.
    ///   - friendId: The ID of the user receiving the request.
    func addRequest(uid: String, friendId: String) async throws {
        try await firestoreDataSource.addRequest(uid: uid, friendId: friendId)
    }
    
    /// Removes a friend from both the current user's and the friend's 'friends' subcollections in Firestore.
    /// - Parameters:
    ///   - uid: The ID of one of the users.
    ///   - friendId: The ID of the other user.
    func removeFriend(uid: String, friendId: String) async throws {
        try await firestoreDataSource.removeFriend(uid: uid, friendId: friendId)
    }
    
    /// Confirms a friend request by updating the friend status in both users' 'friends' subcollections in Firestore.
    /// - Parameters:
    ///   - uid: The ID of the user confirming the request.
    ///   - friendId: The ID of the user who sent the request.
    func confirmFriend(uid: String, friendId: String) async throws {
        try await firestoreDataSource.confirmFriend(uid: uid, friendId: friendId)
    }
    
    /// Updates a user's daily scores in Firestore.
    /// - Parameters:
    ///   - uid: The ID of the user.
    ///   - newScore: The new score for the day.
    func updateDailyScores(uid: String, newScore: Int) async throws {
        try await firestoreDataSource.updateDailyScores(uid: uid, newScore: newScore)
    }
    
    /// Deletes a user's data from Firestore.
    /// - Parameter uid: The ID of the user to be deleted.
    func deleteUserData(uid:String) async throws {
        try await firestoreDataSource.deleteUserData(uid: uid)
    }
    
    /// Persists the user's image to the Firebase storage.
    ///
    /// - Parameter completionBlock: A closure to handle the result of the image persistence operation.
    func persistimageToStorage (image: UIImage?,completionBlock: @escaping (Result<String,Error>) -> Void){
        firestoreDataSource.persistimageToStorage(image: image, completionBlock: completionBlock)
    }
    
}
