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
    
    func userIsPresent(uid: String, completionBlock: @escaping (Result<Bool, Error>) -> Void) {
        firestoreRepository.userIsPresent(uid: uid) { result in
            switch result {
            case .success(let bool):
                completionBlock(.success(bool))
            case .failure(let error):
                self.messageError = error.localizedDescription
                completionBlock(.failure(error)) // Assuming that an error means the user is not present
            }
        }
    }
    
    func usernameIsPresent(name: String, completionBlock: @escaping (Result<Bool, Error>) -> Void) {
        firestoreRepository.UsernameIsPresent(name: name) { result in
            switch result {
            case .success(let bool):
                completionBlock(.success(bool))
            case .failure(let error):
                completionBlock(.failure(error)) // Assuming that an error means the user is not present
            }
        }
    }

    
    func getUser(uid: String, completionBlock: @escaping (Result<User?,Error>) -> Void) {
        firestoreRepository.getUser(uid: uid){ result in
            switch result {
            case .success(let user):
                completionBlock(.success(user))
            case .failure(let error):
                self.messageError = error.localizedDescription
                completionBlock(.failure(error)) // Assuming that an error means the user is not present
            }
        }
        
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
        firestoreRepository.addNewUser(user: user)
        print("User with email \(user.email) added to firestore")
    }
    
    func modifyUser(uid:String, field: String, value: String, type: String) {
        firestoreRepository.modifyUser(uid:uid, field: field, value: value, type: type)
    }
    
    func deleteUserData(uid: String,completionBlock: @escaping (Result<Bool,Error>)-> Void) {
        firestoreRepository.deleteUserData(uid: uid) { [weak self] result in
            switch result {
            case .success(let bool):
                print("Success in deleting user data")
                completionBlock(.success(bool))
            case .failure(let error):
                self?.messageError = error.localizedDescription
                completionBlock(.failure(error))
            }
        }
    }
}
