//
//  FirestoreViewModel.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 03/04/23.
//

import Foundation
import Combine

// TODO: @MainActor
final class FirestoreViewModel: ObservableObject {
    private let firestoreRepository: FirestoreRepository
    
    @Published var allUsers: [User] = []
    @Published var messageError: String?
    @Published var firestoreUser: User?
    @Published var needUsername: Bool = false
    @Published var requests: [User] = []
    @Published var friends: [User] = []
    @Published var waitingList: [User] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var friendsSubcollection: [Friend] = [] {
        didSet {
            fetchRequestsThenFriendsThenWaitingList()
        }
    }

    private let serialQueue = DispatchQueue(label: "friends.serialQueue")
    private let semaphore = DispatchSemaphore(value: 0)

    func fetchRequestsThenFriendsThenWaitingList() {
        serialQueue.async {
            self.getRequests()
            self.semaphore.wait()
            self.getFriends()
            self.semaphore.wait()
            self.getWaitingList()
        }
    }
    
    init(firestoreRepository: FirestoreRepository = FirestoreRepository()) {
        self.firestoreRepository = firestoreRepository
        getCurrentUser()
        getFriendsSubcollection()
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
    
    func fieldIsPresent (field: String, value: String, completionBlock: @escaping (Result<Bool, Error>)  -> Void) {
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
    
    //FIXME: temporary solution for the implemetation of friends to be tested more
    func getRequests() {
        firestoreRepository.getRequests(friendsSubcollection: friendsSubcollection)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching waiting list: \(error)")
                }
            } receiveValue: { [weak self] users in
                self?.requests = users
                self?.semaphore.signal()
            }
            .store(in: &cancellables)
    }
    
    func getWaitingList() {
        firestoreRepository.getWaitingList(friendsSubcollection: friendsSubcollection)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching waiting list: \(error)")
                }
            } receiveValue: { [weak self] users in
                self?.waitingList = users
                self?.semaphore.signal()
            }
            .store(in: &cancellables)
    }

    func getFriends() {
        firestoreRepository.getFriends(friendsSubcollection: friendsSubcollection)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching waiting list: \(error)")
                }
            } receiveValue: { [weak self] users in
                self?.friends = users
                self?.semaphore.signal()
            }
            .store(in: &cancellables)
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
    
    func modifyUser(uid:String, field: String, value: Any) {
        firestoreRepository.modifyUser(uid:uid, field: field, value: value)
    }
    
    // Overload for arrays of BaseActivity
    func modifyUser(uid: String, field: String, records: [BaseActivity]) {
        firestoreRepository.modifyUser(uid: uid, field: field, records: records)
    }
    
    func updateDailyScores(uid: String, newScore: Int) {
        firestoreRepository.updateDailyScores(uid: uid, newScore: newScore)
    }
    
    func deleteUserData(uid: String, completionBlock: @escaping (Result<Bool,Error>)-> Void) {
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
