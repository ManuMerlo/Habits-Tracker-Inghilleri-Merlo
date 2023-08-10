//
//  FirestoreViewModel.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 03/04/23.
//

import Foundation


final class FirestoreViewModel: ObservableObject {
    private let firestoreRepository: FirestoreRepository
    
    @Published var allUsers: [User] = [] // To use in the leaderboardview together the .task that calls this viewmodel.getAllUsers for realtime updates
    @Published var messageError: String?
    @Published var firestoreUser: User?
    @Published var needUsername: Bool = false
    @Published var friendsSubcollection : [Friend] = []
    @Published var requests: [User] = []
    @Published var friends: [User] = []
    @Published var waitingList: [User] = []
    
    
    init(firestoreRepository: FirestoreRepository = FirestoreRepository()) {
        self.firestoreRepository = firestoreRepository
        getCurrentUser()
        getFriendsSubcollection()
        getFriends()
        getRequests()
        getWaitingList()
    }
    
    func getCurrentUser(){
        firestoreRepository.getCurrentUser { result in
            switch result {
            case .success(let user):
                self.firestoreUser = user
                if let _ = user.username {
                    self.needUsername = false
                } else {
                    self.needUsername = true
                }
            case .failure(let error):
                self.messageError = error.localizedDescription
            }
        }
    }
    
    func fieldIsPresent (field : String, value: String, completionBlock: @escaping (Result<Bool, Error>)  -> Void) {
        firestoreRepository.fieldIsPresent(field:field, value: value) { result in
            switch result {
            case .success(let bool):
                completionBlock(.success(bool))
            case .failure(let error):
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
    
    func getFriendsSubcollection() {
        firestoreRepository.getFriendsSubcollection { friends in
            self.friendsSubcollection = friends ?? []
        }
    }
    
    func getRequests() {
        firestoreRepository.getRequests(friendsSubcollection:friendsSubcollection){ users in
            self.requests = users ?? []
        }
    }
    
    func getWaitingList(){
        firestoreRepository.getWaitingList(friendsSubcollection: friendsSubcollection){ users in
            self.waitingList = users ?? []
        }
    }
    func getFriends(){
        firestoreRepository.getFriends (friendsSubcollection: friendsSubcollection){ users in
            self.friends = users ?? []
        }
    }
    
    func addNewUser(user: User) {
        firestoreRepository.addNewUser(user: user)
        print("User with email \(user.email) added to firestore")
    }
    
    func addRequest(uid: String, friend: String) {
        firestoreRepository.addRequest(uid: uid, friend: friend)
    }
    
    func removeFriend(uid: String, friend: String) {
        firestoreRepository.removeFriend(uid: uid, friend: friend)
    }
    
    func confirmFriend(uid: String, friendId: String) {
        firestoreRepository.confirmFriend(uid: uid, friendId: friendId)
    }
    
    func modifyUser(uid:String, field: String, value: String, type: String) {
        firestoreRepository.modifyUser(uid:uid, field: field, value: value, type: type)
    }
    
    func updateDailyScores(uid: String, newScore: Int) {
        firestoreRepository.updateDailyScores(uid: uid, newScore: newScore)
    }
    
    func deleteUserData(uid: String,completionBlock: @escaping (Result<Bool,Error>)-> Void) {
        firestoreRepository.deleteUserData(uid: uid) { [weak self] result in
            switch result {
            case .success(let bool):
                self?.firestoreUser = nil
                print("Success in deleting user data")
                completionBlock(.success(bool))
            case .failure(let error):
                self?.messageError = error.localizedDescription
                completionBlock(.failure(error))
            }
        }
    }
}
