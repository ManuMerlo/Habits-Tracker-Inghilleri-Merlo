import Foundation
import Combine

@MainActor
final class FirestoreViewModel: ObservableObject {
    private let firestoreRepository: FirestoreRepository
    
    @Published var allUsers: [User] = []
    @Published var messageError: String?
    @Published /*private(set)*/ var firestoreUser: User? = nil // TODO: set
    @Published var needUsername: Bool = false
    // @Published var requests: [User] = []
    // @Published var friends: [User] = []
    // @Published var waitingList: [User] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private(set) var friendsSubcollection: [Friend] = [] /* TODO: {
        didSet {
            fetchRequestsThenFriendsThenWaitingList()
        }
    }*/

    //private let serialQueue = DispatchQueue(label: "friends.serialQueue")
    //private let semaphore = DispatchSemaphore(value: 0)

    /*TODO: func fetchRequestsThenFriendsThenWaitingList() {
        serialQueue.async {
            self.getRequests()
            self.semaphore.wait()
            self.getFriends()
            self.semaphore.wait()
            self.getWaitingList()
        }
    }*/
    
    init(firestoreRepository: FirestoreRepository = FirestoreRepository()) {
        self.firestoreRepository = firestoreRepository
        // getCurrentUser()
        // getFriendsSubcollection()
    }
    
    func getCurrentUser() async throws {
        self.firestoreUser = try await firestoreRepository.getCurrentUser()
        if let user = self.firestoreUser, user.username == nil {
            self.needUsername = true
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
    
    //FIXME: temporary solution for the implemetation of friends to be tested more
    /*func getRequests() {
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
    }*/

    func addNewUser(user: User) {
        firestoreRepository.addNewUser(user: user)
        print("User with email \(user.email) added to firestore")
    }
    
    func addRequest(uid: String, friendId: String) async {
        do {
            try await firestoreRepository.addRequest(uid: uid, friendId: friendId)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeFriend(uid: String, friendId: String) async {
        do {
            try await firestoreRepository.removeFriend(uid: uid, friendId: friendId)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func confirmFriend(uid: String, friendId: String) async {
        do {
            try await firestoreRepository.confirmFriend(uid: uid, friendId: friendId)
        } catch {
            print(error.localizedDescription)
        }
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
