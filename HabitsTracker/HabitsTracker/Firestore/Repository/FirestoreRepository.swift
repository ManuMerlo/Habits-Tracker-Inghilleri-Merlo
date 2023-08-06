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
    
    func userIsPresent (uid : String, completionBlock: @escaping (Result<Bool, Error>) -> Void){
        self.firestoreDataSource.userIsPresent(uid: uid, completionBlock: completionBlock)
    }
    
    func fieldIsPresent (field : String, value: String, completionBlock: @escaping (Result<Bool, Error>)  -> Void){
        self.firestoreDataSource.fieldIsPresent(field: field,value:value, completionBlock: completionBlock)
    }
    
    func getUser(uid: String, completionBlock: @escaping (Result<User?,Error>) -> Void) {
        self.firestoreDataSource.getUser(uid: uid, completionBlock: completionBlock)
    }
    
    func getAllUsers(completionBlock: @escaping (Result<[User], Error>) -> Void) {
        firestoreDataSource.getAllUsers(completionBlock: completionBlock)
    }
    
    func addNewUser(user: User) {
        firestoreDataSource.addNewUser(user: user)
    }
    
    func modifyUser(uid:String, field: String, value: String, type: String){
        firestoreDataSource.modifyUser(uid:uid, field: field, value: value, type: type)
    }
    
    func deleteUserData(uid:String,completionBlock: @escaping (Result<Bool, Error>) -> Void) {
        firestoreDataSource.deleteUserData( uid: uid, completionBlock: completionBlock)
    }
}
