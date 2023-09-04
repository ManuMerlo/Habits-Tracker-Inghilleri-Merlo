import Foundation
import UIKit
import Combine

/// `FirestoreViewModel` is responsible for managing and binding Firestore data operations
/// to the UI. It serves as a bridge between the UI and the underlying data layer provided
/// by `FirestoreRepository`.
@MainActor
final class FirestoreViewModel: ObservableObject {
    private let firestoreRepository: FirestoreRepository
    private(set) var tasks: [Task<Void, Never>] = []
    
    @Published var messageError: String?
    @Published var firestoreUser: User? = nil
    @Published var needUsername: Bool = false
    @Published var requests: [User] = []
    @Published private(set) var friendsSubcollection: [Friend] = []
    
    /// Initializes a new instance of the ViewModel with the default Firestore repository.
    init(firestoreRepository: FirestoreRepository = FirestoreRepository()) {
        self.firestoreRepository = firestoreRepository
    }
    
    /// Initializes a new instance of the ViewModel for testing purposes.
    init(withRepository firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
    }
    
    /// Cancels all ongoing tasks associated with the ViewModel.
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    /// Adds a listener to detect changes in the authenticated user's data.
    /// - Parameter completion: A closure to handle the result of the fetch.
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
    
    /// Removes the listener for the authenticated user's data.
    func removeListenerForCurrentUser() {
        firestoreRepository.removeListenerForCurrentUser()
    }
    
    /// Adds a listener to detect changes in the user's friend subcollection.
    func addListenerForFriendsSubcollection() {
        firestoreRepository.addListenerForFriendsSubcollection { [weak self] friends in
            self?.friendsSubcollection = friends
        }
    }
    
    /// Removes the listener for the user's friend subcollection.
    func removeListenerForFriendsSubcollection() {
        firestoreRepository.removeListenerForFriendsSubcollection()
    }
    
    /// Checks if a field with the specified value exists.
    /// - Parameters:
    ///     - field: The field to check.
    ///     - value: The value of the field.
    /// - Throws: If there was an error in the fetch.
    /// - Returns: A boolean indicating the presence of the field-value pair.
    func fieldIsPresent(field: String, value: String) async throws -> Bool {
        return try await firestoreRepository.fieldIsPresent(field: field, value: value)
    }
    
    /// Fetches friend request information.
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
    
    /// Adds a new user.
    /// - Parameter user: The user object to add.
    func addNewUser(user: User) {
        firestoreRepository.addNewUser(user: user)
    }
    
    /// Sends a friend request.
    /// - Parameters:
    ///     - uid: The user's ID.
    ///     - friendId: The ID of the friend to add.
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
    
    /// Removes a friend.
    /// - Parameters:
    ///     - uid: The user's ID.
    ///     - friendId: The friend's ID to remove.
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
    
    /// Confirms a friend request.
    /// - Parameters:
    ///     - uid: The user's ID.
    ///     - friendId: The friend's ID to confirm.
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
    
    /// Modifies a specific field of a user.
    /// - Parameters:
    ///     - uid: The user's ID.
    ///     - field: The field to modify.
    ///     - value: The new value for the field.
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
    
    /// Modifies a user's field with an array of BaseActivity.
    /// - Parameters:
    ///     - uid: The user's ID.
    ///     - field: The field to modify.
    ///     - newScores: The new array of scores.
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
    
    /// Updates the daily scores of a user.
    /// - Parameters:
    ///     - uid: The user's ID.
    ///     - newScore: The new daily score.
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
    
    /// Persists the user's image to the Firebase storage.
    ///
    /// - Parameter completionBlock: A closure to handle the result of the image persistence operation.
    func persistimageToStorage (image: UIImage?,completionBlock: @escaping (Result<String,Error>) -> Void){
        firestoreRepository.persistimageToStorage(image: image) { result in
            switch result {
            case .success(let url):
                completionBlock(.success(url))
            case .failure(_):
                completionBlock(.failure(DBError.badDBResponse))
            }
        }
    }
    
    /// Deletes all data associated with a user.
    /// - Parameter uid: The user's ID.
    func deleteUserData(uid: String) async throws {
        try await firestoreRepository.deleteUserData(uid: uid)
    }
    
    /// Retrieves the status of a friend.
    /// - Parameter friendId: The friend's ID.
    /// - Returns: The status of the friend.
    func getFriendStatus(friendId: String) -> FriendStatus? {
        return friendsSubcollection.first { friend in
            friend.id == friendId
        }?.status
    }
    
    /// Retrieves IDs of friends with a specific status.
    /// - Parameter status: The friend status to filter by.
    /// - Returns: An array of friend IDs.
    func getFriendsIdsWithStatus(status: FriendStatus) -> [String] {
        return friendsSubcollection.filter { friend in
            friend.status == status
        }.map { $0.id }
    }
}
