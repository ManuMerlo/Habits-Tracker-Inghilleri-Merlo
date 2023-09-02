import Foundation

final class FirestoreRepository {
    private let firestoreDataSource: FirestoreDataSourceProtocol
    
    init(firestoreDataSource: FirestoreDataSource = FirestoreDataSource()) {
        self.firestoreDataSource = firestoreDataSource
    }
    
    //Second initializer for test purposes
    init(withDataSource firestoreDataSource: FirestoreDataSourceProtocol) {
        self.firestoreDataSource = firestoreDataSource
    }
    
    func addListenerForCurrentUser(completionBlock: @escaping (Result<User, Error>) -> Void) {
        firestoreDataSource.addListenerForCurrentUser(completionBlock: completionBlock)
    }
    
    func removeListenerForCurrentUser() {
        firestoreDataSource.removeListenerForCurrentUser()
    }
    
    func fieldIsPresent (field: String, value: String) async throws -> Bool {
        return try await firestoreDataSource.fieldIsPresent(field: field, value:value)
    }
    
    func addNewUser(user: User) {
        firestoreDataSource.addNewUser(user: user)
    }
        
    func addListenerForFriendsSubcollection(completionBlock: @escaping([Friend]) -> Void) {
        firestoreDataSource.addListenerForFriendsSubcollection(completionBlock: completionBlock)
    }
    
    func removeListenerForFriendsSubcollection() {
        firestoreDataSource.removeListenerForFriendsSubcollection()
    }
    
    func getRequests(requestFriendsIDs: [String]) async throws -> [User] {
        return try await firestoreDataSource.getRequests(requestFriendsIDs: requestFriendsIDs)
    }
    
    func modifyUser(uid:String, field: String, value: Any) async throws {
        try await firestoreDataSource.modifyUser(uid:uid, field: field, value: value)
    }
    
    // Overload for arrays of BaseActivity
    func modifyUser(uid: String, field: String, newScores: [BaseActivity]) async throws {
        try await firestoreDataSource.modifyUser(uid: uid, field: field, newScores: newScores)
    }
    
    func addRequest(uid: String, friendId: String) async throws {
        try await firestoreDataSource.addRequest(uid: uid, friendId: friendId)
    }
    
    func removeFriend(uid: String, friendId: String) async throws {
        try await firestoreDataSource.removeFriend(uid: uid, friendId: friendId)
    }
    
    func confirmFriend(uid: String, friendId: String) async throws {
        try await firestoreDataSource.confirmFriend(uid: uid, friendId: friendId)
    }
    
    func updateDailyScores(uid: String, newScore: Int) async throws {
        try await firestoreDataSource.updateDailyScores(uid: uid, newScore: newScore)
    }

    func deleteUserData(uid:String) async throws {
        try await firestoreDataSource.deleteUserData(uid: uid)
    }
}
