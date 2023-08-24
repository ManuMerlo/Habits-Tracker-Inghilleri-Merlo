import Foundation
import Combine

@MainActor
final class FirestoreViewModel: ObservableObject {
    private let firestoreRepository: FirestoreRepository
    private var tasks: [Task<Void, Never>] = []
    
    @Published var allUsers: [User] = []
    @Published var messageError: String?
    @Published /*private(set)*/ var firestoreUser: User? = nil // TODO: set
    @Published var needUsername: Bool = false
    @Published var requests: [User] = []
    
    //private var cancellables: Set<AnyCancellable> = []
    
    // function to cancel all tasks
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    @Published private(set) var friendsSubcollection: [Friend] = [] /* TODO: {
        didSet {
            fetchRequestsThenFriendsThenWaitingList()
        }
    }*/
    
    init(firestoreRepository: FirestoreRepository = FirestoreRepository()) {
        self.firestoreRepository = firestoreRepository
    }
    
    /*func getCurrentUser() async throws {
        self.firestoreUser = try await firestoreRepository.getCurrentUser()
        if let user = self.firestoreUser, user.username == nil {
            self.needUsername = true
        }
    }*/
    
    // Listener
    func getCurrentUser() {
        firestoreRepository.getCurrentUser { [weak self] result in
            switch result {
            case .success(let user):
                self?.firestoreUser = user
                if let _ = user.username {
                    self?.needUsername = false
                } else {
                    self?.needUsername = true
                }
            case .failure(let error):
                self?.messageError = error.localizedDescription
            }
        }
    }
    
    func removeListenerForCurrentUser() {
        firestoreRepository.removeListenerForCurrentUser()
    }
    
    func fieldIsPresent(field: String, value: String) async throws -> Bool {
        return try await firestoreRepository.fieldIsPresent(field: field, value: value)
    }
    
    /*func getAllUsers() {
        firestoreRepository.getAllUsers { [weak self] result in
            switch result {
            case .success(let users):
                self?.allUsers = users
            case .failure(let error):
                self?.messageError = error.localizedDescription
            }
        }
    }*/
    
    func getFriendsSubcollection() {
        firestoreRepository.getFriendsSubcollection { [weak self] friends in
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
                print(error.localizedDescription)
            }
        }
        tasks.append(task)
    }
    
    /*func getWaitingList() {
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
    }*/

    func addNewUser(user: User) {
        firestoreRepository.addNewUser(user: user)
        print("User with email \(user.email) added to firestore")
    }
    
    func addRequest(uid: String, friendId: String) {
        let task = Task {
            do {
                try await firestoreRepository.addRequest(uid: uid, friendId: friendId)
            } catch {
                print(error.localizedDescription)
            }
        }
        tasks.append(task)
    }
    
    func removeFriend(uid: String, friendId: String) {
        let task = Task {
            do {
                try await firestoreRepository.removeFriend(uid: uid, friendId: friendId)
            } catch {
                print(error.localizedDescription)
            }
        }
        tasks.append(task)
    }
    
    func confirmFriend(uid: String, friendId: String) {
        let task = Task {
            do {
                try await firestoreRepository.confirmFriend(uid: uid, friendId: friendId)
            } catch {
                print(error.localizedDescription)
            }
        }
        tasks.append(task)
    }
    
    func modifyUser(uid:String, field: String, value: Any) {
        let task = Task {
            do {
                try await firestoreRepository.modifyUser(uid:uid, field: field, value: value)
            } catch {
                print(error.localizedDescription)
            }
        }
        tasks.append(task)
    }
    
    // Overload for arrays of BaseActivity
    func modifyUser(uid: String, field: String, records: [BaseActivity]) {
        let task = Task {
            do {
                try await firestoreRepository.modifyUser(uid: uid, field: field, records: records)
            } catch {
                print(error.localizedDescription)
            }
        }
        tasks.append(task)
    }
    
    func updateDailyScores(uid: String, newScore: Int) {
        let task = Task {
            do {
                try await firestoreRepository.updateDailyScores(uid: uid, newScore: newScore)
            } catch {
                print(error)
                // FIXME:error
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
