import Foundation
import Combine

@MainActor
final class FirestoreViewModel: ObservableObject {
    private let firestoreRepository: FirestoreRepository
    private(set) var tasks: [Task<Void, Never>] = []
    
    @Published var messageError: String?
    @Published var firestoreUser: User? = nil
    @Published var needUsername: Bool = false
    @Published var requests: [User] = []
    @Published private(set) var friendsSubcollection: [Friend] = []
    
    // Default initializer
    init(firestoreRepository: FirestoreRepository = FirestoreRepository()) {
        self.firestoreRepository = firestoreRepository
    }
    
    // Initializer for test purposes
    init(withRepository firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
    }
    
    // function to cancel all tasks
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    func addListenerForCurrentUser(completion: @escaping (Error?) -> Void) {
        firestoreRepository.addListenerForCurrentUser { [weak self] result in
            switch result {
            case .success(let user):
                self?.firestoreUser = user
                if let _ = user.username {
                    self?.needUsername = false
                } else {
                    self?.needUsername = true
                }
                completion(nil) // No error occurred
            case .failure(_):
                self?.messageError = DBError.failedUserRetrieval.description
                completion(DBError.failedUserRetrieval)
            }
        }
    }
    
    func removeListenerForCurrentUser() {
        firestoreRepository.removeListenerForCurrentUser()
    }
    
    func fieldIsPresent(field: String, value: String) async throws -> Bool {
        return try await firestoreRepository.fieldIsPresent(field: field, value: value)
    }
    
    func addListenerForFriendsSubcollection() {
        firestoreRepository.addListenerForFriendsSubcollection { [weak self] friends in
            self?.friendsSubcollection = friends
        }
    }
    
    func removeListenerForFriendsSubcollection() {
        firestoreRepository.removeListenerForFriendsSubcollection()
    }
    
    func getRequests() {
        let task = Task {
            do {
                requests = try await firestoreRepository.getRequests(requestFriendsIDs: getFriendsIdsWithStatus(status: FriendStatus.Request))
            } catch {
                self.messageError = DBError.badDBResponse.description
            }
        }
        tasks.append(task)
    }
    
    func addNewUser(user: User) {
        firestoreRepository.addNewUser(user: user)
        print("User with email \(user.email) added to firestore")
    }
    
    func addRequest(uid: String, friendId: String) {
        let task = Task {
            do {
                try await firestoreRepository.addRequest(uid: uid, friendId: friendId)
            } catch {
                self.messageError = DBError.badDBResponse.description
            }
        }
        tasks.append(task)
    }
    
    func removeFriend(uid: String, friendId: String) {
        let task = Task {
            do {
                try await firestoreRepository.removeFriend(uid: uid, friendId: friendId)
            } catch {
                self.messageError = DBError.badDBResponse.description
            }
        }
        tasks.append(task)
    }
    
    func confirmFriend(uid: String, friendId: String) {
        let task = Task {
            do {
                try await firestoreRepository.confirmFriend(uid: uid, friendId: friendId)
            } catch {
                self.messageError = DBError.badDBResponse.description
            }
        }
        tasks.append(task)
    }
    
    func modifyUser(uid:String, field: String, value: Any) {
        let task = Task {
            do {
                try await firestoreRepository.modifyUser(uid:uid, field: field, value: value)
            } catch {
                self.messageError = DBError.badDBResponse.description
            }
        }
        tasks.append(task)
    }
    
    // Overload for arrays of BaseActivity
    func modifyUser(uid: String, field: String, newScores: [BaseActivity]) {
        let task = Task {
            do {
                try await firestoreRepository.modifyUser(uid: uid, field: field, newScores: newScores)
            } catch {
                self.messageError = DBError.badDBResponse.description
            }
        }
        tasks.append(task)
    }
    
    func updateDailyScores(uid: String, newScore: Int) {
        let task = Task {
            do {
                try await firestoreRepository.updateDailyScores(uid: uid, newScore: newScore)
            } catch {
                self.messageError = DBError.badDBResponse.description
            }
        }
        tasks.append(task)
    }
    
    func deleteUserData(uid: String) async throws {
        try await firestoreRepository.deleteUserData(uid: uid)
    }
    
    func getFriendStatus(friendId: String) -> FriendStatus? {
        return friendsSubcollection.first { friend in
            friend.id == friendId
        }?.status
    }
    
    func getFriendsIdsWithStatus(status: FriendStatus) -> [String] {
        return friendsSubcollection.filter { friend in
            friend.status == status
        }.map { $0.id }
    }
}
