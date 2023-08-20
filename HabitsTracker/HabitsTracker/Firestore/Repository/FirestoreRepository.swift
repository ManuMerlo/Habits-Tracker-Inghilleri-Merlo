import Foundation
import Combine

final class FirestoreRepository {
    private let firestoreDataSource: FirestoreDataSource
    
    init(firestoreDataSource: FirestoreDataSource = FirestoreDataSource()) {
        self.firestoreDataSource = firestoreDataSource
    }
    
    /*func getCurrentUser(completionBlock: @escaping (Result<User, Error>) -> Void) {
        firestoreDataSource.getCurrentUser(completionBlock: completionBlock)
    }*/
    
    func getCurrentUser() async throws -> User {
        return try await firestoreDataSource.getCurrentUser()
    }
    
    func fieldIsPresent (field : String, value: String, completionBlock: @escaping (Result<Bool, Error>)  -> Void){
        self.firestoreDataSource.fieldIsPresent(field: field,value:value, completionBlock: completionBlock)
    }
    
    /*func getAllUsers(completionBlock: @escaping (Result<[User], Error>) -> Void) {
        firestoreDataSource.getAllUsers(completionBlock: completionBlock)
    }*/
    
    func addNewUser(user: User) {
        firestoreDataSource.addNewUser(user: user)
    }
        
    func getFriendsSubcollection(completionBlock: @escaping([Friend]) -> Void) {
        firestoreDataSource.getFriendsSubcollection(completionBlock: completionBlock)
    }
    
    func removeListenerForFriendsSubcollection() {
        firestoreDataSource.removeListenerForFriendsSubcollection()
    }
    
    /*func getFriends(friendsSubcollection: [Friend]) -> AnyPublisher<[User], Error> {
        firestoreDataSource.getFriends(friendsSubcollection: friendsSubcollection)
    }
    
    func getRequests(friendsSubcollection: [Friend]) -> AnyPublisher<[User], Error> {
        return firestoreDataSource.getRequests(friendsSubcollection: friendsSubcollection)
    }
    
    func getWaitingList(friendsSubcollection: [Friend]) -> AnyPublisher<[User], Error> {
        return firestoreDataSource.getWaitingList(friendsSubcollection: friendsSubcollection)
    }*/
    
    func modifyUser(uid:String, field: String, value: Any){
        return firestoreDataSource.modifyUser(uid:uid, field: field, value: value)
    }
    
    // Overload for arrays of BaseActivity
    func modifyUser(uid: String, field: String, records: [BaseActivity]) {
        firestoreDataSource.modifyUser(uid: uid, field: field, records: records)
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
    
    func updateDailyScores(uid: String, newScore: Int) {
        firestoreDataSource.updateDailyScores(uid: uid, newScore: newScore)
    }
    
    /*func deleteUserData(uid:String,completionBlock: @escaping (Result<Bool, Error>) -> Void) {
        firestoreDataSource.deleteUserData( uid: uid, completionBlock: completionBlock)
    }*/
    
    func deleteUserData(uid:String) async throws {
        try await firestoreDataSource.deleteUserData(uid: uid)
    }
}
