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
    
    func getAllUsers(completionBlock: @escaping (Result<[User], Error>) -> Void) {
        firestoreDataSource.getAllUsers(completionBlock: completionBlock)
    }
    
    // TODO: add user
    func addNewUser(user: User, completionBlock: @escaping (Result<User, Error>) -> Void) {
        firestoreDataSource.addNewUser(user: user, completionBlock: completionBlock)
    }
}
