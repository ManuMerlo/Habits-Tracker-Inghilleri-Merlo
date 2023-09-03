import Foundation

// MARK: - FirestoreDataSourceProtocol

/// Protocol defining the CRUD operations and Firestore data access methods required for the app.
protocol FirestoreDataSourceProtocol {
    
    // MARK: - Listeners
        
    /// Adds a listener for the current user's data and retrieves it from Firestore.
    /// - Parameter completionBlock: Closure to handle the fetched User data.
    func addListenerForCurrentUser(completionBlock: @escaping (Result<User, Error>) -> Void)
    
    /// Removes the listener for the current user's data.
    func removeListenerForCurrentUser()
    
    /// Adds a listener for the current user's friends' subcollection and retrieves it from Firestore.
    /// - Parameter completionBlock: Closure to handle the fetched array of Friend data.
    func addListenerForFriendsSubcollection(completionBlock: @escaping([Friend]) -> Void)
    
    /// Removes the listener for the current user's friends' subcollection.
    func removeListenerForFriendsSubcollection()
    
    // MARK: - CRUD for User
    
    /// Adds a new User document to Firestore.
    /// - Parameter user: The User object to be added.
    func addNewUser(user: User)
    
    /// Modifies a specific field of a User document in Firestore.
    /// - Parameters:
    ///   - uid: The ID of the user.
    ///   - field: The name of the field to be modified.
    ///   - value: The new value to be set for the field.
    func modifyUser(uid: String, field: String, value: Any) async throws
    
    /// Modifies a User's BaseActivity array in Firestore.
    /// - Parameters:
    ///   - uid: The ID of the user.
    ///   - field: The name of the field to be modified.
    ///   - newScores: The new array of BaseActivity objects.
    func modifyUser(uid: String, field: String, newScores: [BaseActivity]) async throws
    
    /// Deletes a User document from Firestore.
    /// - Parameter uid: The ID of the user to be deleted.
    func deleteUserData(uid: String) async throws
    
    /// Updates the daily scores for a User in Firestore.
    /// - Parameters:
    ///   - uid: The ID of the user.
    ///   - newScore: The new score to be added for the day.
    func updateDailyScores(uid: String, newScore: Int) async throws
    
    /// Checks if a specific field with a given value exists in the users collection.
    /// - Parameters:
    ///   - field: The name of the field to be checked.
    ///   - value: The value to be checked for.
    func fieldIsPresent(field: String, value: String) async throws -> Bool
    
    // MARK: - Friends Operations
    
    /// Adds a friend request between two users in Firestore.
    /// - Parameters:
    ///   - uid: The ID of the user sending the request.
    ///   - friendId: The ID of the user receiving the request.
    func addRequest(uid: String, friendId: String) async throws
    
    /// Removes a friend relationship between two users in Firestore.
    /// - Parameters:
    ///   - uid: The ID of one of the users.
    ///   - friendId: The ID of the other user.
    func removeFriend(uid: String, friendId: String) async throws
    
    /// Confirms a friend request between two users in Firestore.
    /// - Parameters:
    ///   - uid: The ID of the user confirming the request.
    ///   - friendId: The ID of the user who sent the request.
    func confirmFriend(uid: String, friendId: String) async throws
    
    /// Retrieves a list of User objects based on provided friend request IDs.
    /// - Parameter requestFriendsIDs: An array of user IDs who have sent friend requests.
    func getRequests(requestFriendsIDs: [String]) async throws -> [User]
    
    /// Helper function to handle and print errors from Firestore update operations.
    /// - Parameter err: The error, if any, from the update operation.
    func handleUpdateResult(err: Error?)
}
