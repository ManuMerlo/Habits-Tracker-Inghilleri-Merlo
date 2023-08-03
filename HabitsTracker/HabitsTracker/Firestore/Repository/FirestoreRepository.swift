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
    
    func getAllUsers(completionBlock: @escaping (Result<[User], Error>) -> Void) {
        firestoreDataSource.getAllUsers(completionBlock: completionBlock)
    }
    
    func addNewUser(user: User) {
        firestoreDataSource.addNewUser(user: user)
    }
}
