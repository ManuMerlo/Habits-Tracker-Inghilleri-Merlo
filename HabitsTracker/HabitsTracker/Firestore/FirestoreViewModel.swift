//
//  FirestoreViewModel.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 03/04/23.
//

import Foundation

final class FirestoreViewModel: ObservableObject {
    @Published var allUsers: [User] = [] // To use in the leaderboardview together the .task that calls this viewmodel.getAllUsers for realtime updates
    @Published var messageError: String?
    private let firestoreRepository: FirestoreRepository
    
    init(firestoreRepository: FirestoreRepository = FirestoreRepository()) {
        self.firestoreRepository = firestoreRepository
    }
    
    func getAllUsers() {
        firestoreRepository.getAllUsers { [weak self] result in
            switch result {
            case .success(let users):
                self?.allUsers = users
            case .failure(let error):
                self?.messageError = error.localizedDescription
            }
        }
    }
    
    func addNewUser(user: User) {
        firestoreRepository.addNewUser(user: user) { [weak self] result in
            switch result {
            case .success(let user):
                print("User with email \(user.email) added into firestore")
            case .failure(let error):
                self?.messageError = error.localizedDescription
            }
        }
    }
}
