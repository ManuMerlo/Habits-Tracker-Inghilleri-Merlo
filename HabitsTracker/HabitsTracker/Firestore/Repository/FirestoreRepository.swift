//
//  FirestoreRepository.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 03/04/23.
//

import Foundation

final class FirestoreRepository {
    private let firestoreDataSource: FirestoreDataSource
    
    init(firestoreDataSource: FirestoreDataSource = FirestoreDataSource()) {
        self.firestoreDataSource = firestoreDataSource
    }
    
    func getCurrentUser(completionBlock: @escaping (Result<User, Error>) -> Void) {
        firestoreDataSource.getCurrentUser(completionBlock: completionBlock)
    }
    
    func fieldIsPresent (field : String, value: String, completionBlock: @escaping (Result<Bool, Error>)  -> Void){
        self.firestoreDataSource.fieldIsPresent(field: field,value:value, completionBlock: completionBlock)
    }
    
    func getAllUsers(completionBlock: @escaping (Result<[User], Error>) -> Void) {
        firestoreDataSource.getAllUsers(completionBlock: completionBlock)
    }
    
    func addNewUser(user: User) {
        firestoreDataSource.addNewUser(user: user)
    }
        
    func getFriendsSubcollection(completionBlock: @escaping([Friend]?) -> Void) {
        firestoreDataSource.getFriendsSubcollection(completionBlock: completionBlock)
    }
    
    func getFriends(friendsSubcollection:[Friend], completionBlock: @escaping ([User]?) -> Void) {
        firestoreDataSource.getFriends(friendsSubcollection: friendsSubcollection, completionBlock: completionBlock)
    }
    
    func getRequests(friendsSubcollection:[Friend], completionBlock: @escaping ([User]?) -> Void) {
        firestoreDataSource.getRequests(friendsSubcollection: friendsSubcollection, completionBlock: completionBlock)
    }
    
    func getWaitingList(friendsSubcollection:[Friend], completionBlock: @escaping ([User]?) -> Void) {
        firestoreDataSource.getWaitingList(friendsSubcollection: friendsSubcollection, completionBlock: completionBlock)
    }
    
    func modifyUser(uid:String, field: String, value: Any){
        firestoreDataSource.modifyUser(uid:uid, field: field, value: value)
    }
    
    // Overload for arrays of BaseActivity
    func modifyUser(uid: String, field: String, records: [BaseActivity]) {
        firestoreDataSource.modifyUser(uid: uid, field: field, records: records)
    }
    
    func addRequest(uid: String, friend: String) {
        firestoreDataSource.addRequest(uid: uid, friend: friend)
    }
    
    func removeFriend(uid: String, friend: String) {
        firestoreDataSource.removeFriend(uid: uid, friend: friend)
    }
    
    func confirmFriend(uid: String, friendId: String) {
        firestoreDataSource.confirmFriend(uid: uid, friendId: friendId)
    }
    
    func updateDailyScores(uid: String, newScore: Int) {
        firestoreDataSource.updateDailyScores(uid: uid, newScore: newScore)
    }
    
    func deleteUserData(uid:String,completionBlock: @escaping (Result<Bool, Error>) -> Void) {
        firestoreDataSource.deleteUserData( uid: uid, completionBlock: completionBlock)
    }
}
