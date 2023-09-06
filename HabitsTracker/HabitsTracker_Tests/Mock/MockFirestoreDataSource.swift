import Foundation
import UIKit
@testable import HabitsTracker

final class MockFirestoreDataSource : FirestoreDataSourceProtocol, Mockable{
    
    var inMemoryUsers: [User] = []
    var inMemoryFriends: [Friend] = []
    var throwError: Bool = false

    // Default Initialization
    init() {
        inMemoryUsers = loadJSON(filename: "Users", type: User.self)
        inMemoryFriends = loadJSON(filename: "FriendsSubcollection", type: Friend.self)
        throwError = false
    }

    // Initialization with provided users, friends, and throwError value
    init(users: [User]? = nil, friends: [Friend]? = nil, throwError: Bool? = false) {
        self.inMemoryUsers = users ?? loadJSON(filename: "Users", type: User.self)
        self.inMemoryFriends = friends ?? loadJSON(filename: "FriendsSubcollection", type: Friend.self)
        self.throwError = throwError ?? false
    }
    
    // Add listener for current user
    func addListenerForCurrentUser(completionBlock: @escaping (Result<User,Error>) -> Void) {
        // Assumption: the current user is the first one
        if let user = inMemoryUsers.first {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                completionBlock(.success(user))
            }
        } else {
            completionBlock(.failure(NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey: "Mock User Not Found"])))
        }
        
    }
    
    func removeListenerForCurrentUser() {
        //
    }
    
    // Mock logic for checking if field is present
    func fieldIsPresent(field: String, value: String) async throws -> Bool {
        if throwError{
            throw DBError.badDBResponse
        } else {
            
            for user in inMemoryUsers {
                switch field {
                case "id":
                    if user.id == value { return true }
                case "email":
                    if user.email == value { return true }
                case "username":
                    if user.username == value { return true }
                case "birthDate":
                    if user.birthDate == value { return true }
                case "image":
                    if user.image == value { return true }
                case "dailyGlobal":
                    if let dailyGlobal = user.dailyGlobal, "\(dailyGlobal)" == value { return true }
                case "dailyPrivate":
                    if let dailyPrivate = user.dailyPrivate, "\(dailyPrivate)" == value { return true }
                case "weeklyGlobal":
                    if let weeklyGlobal = user.weeklyGlobal, "\(weeklyGlobal)" == value { return true }
                case "weeklyPrivate":
                    if let weeklyPrivate = user.weeklyPrivate, "\(weeklyPrivate)" == value { return true }
                case "sex":
                    if user.sex?.rawValue == value { return true }
                case "height":
                    if let height = user.height, "\(height)" == value { return true }
                case "weight":
                    if let weight = user.weight, "\(weight)" == value { return true }
                default:
                    continue
                }
            }
            return false
        }
    }
    
    
    // Mock logic for friends subcollection listener
    func addListenerForFriendsSubcollection(completionBlock: @escaping([Friend]) -> Void) {
        // Return mock friend list
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            completionBlock(self.inMemoryFriends)
        }
    }
    
    func removeListenerForFriendsSubcollection() {
        //
    }
    
    // Mock logic for getting requests
    func getRequests(requestFriendsIDs: [String]) async throws -> [User] {
        guard !requestFriendsIDs.isEmpty else {
            return []
        }
        
        if throwError {
            throw DBError.badDBResponse
        }
        else {
            try await Task.sleep(nanoseconds: 3_000_000_000)
            return inMemoryUsers.filter{ requestFriendsIDs.contains($0.id) }
        }
    }
    
    func addNewUser(user: User) {
        inMemoryUsers.append(user)
    }
    
    func modifyUser(uid: String, field: String, value: Any) async throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        if throwError{
            throw DBError.badDBResponse
        } else {
            for (index, user) in inMemoryUsers.enumerated() where user.id == uid {
                do {
                    let userData = try encoder.encode(user)
                    var userDict = try JSONSerialization.jsonObject(with: userData, options: .mutableContainers) as! [String: Any]
                    
                    userDict[field] = value
                    
                    let updatedUserData = try JSONSerialization.data(withJSONObject: userDict, options: .fragmentsAllowed)
                    let updatedUser = try decoder.decode(User.self, from: updatedUserData)
                    
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                    inMemoryUsers[index] = updatedUser
                    return
                    
                } catch {
                    throw error
                }
            }
        }
    }

    
    // Overload for arrays of BaseActivity
    func modifyUser(uid: String, field: String, newScores: [BaseActivity]) async throws {
        let dictionaryRecords = newScores.map { $0.asDictionary() }
        try await modifyUser(uid: uid, field: field, value: dictionaryRecords)
    }
    
    // Mock logic for adding friend request
    func addRequest(uid: String, friendId: String) async throws {
        if throwError{
            throw DBError.badDBResponse
        } else {
            let friend = Friend(id: friendId, status: .Waiting)
            try await Task.sleep(nanoseconds: 3_000_000_000)
            inMemoryFriends.append(friend)
        }
    }
    
    // Mock logic to remove a friend
    func removeFriend(uid: String, friendId: String) async throws {
        if throwError{
            throw DBError.badDBResponse
        } else {
            try await Task.sleep(nanoseconds: 3_000_000_000)
            if let index = inMemoryFriends.firstIndex(where: { $0.id == friendId && $0.status == .Confirmed }) {
                inMemoryFriends.remove(at: index)
            }
        }
    }
    
    // Mock logic to confirm a friend
    func confirmFriend(uid: String, friendId: String) async throws {
        if throwError{
            throw DBError.badDBResponse
        } else {
        // Find the friend with the given friendId
            if let index = inMemoryFriends.firstIndex(where: { $0.id == friendId && $0.status == .Request }) {
                
                    // Sleep for 3 seconds
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                    
                    // Modify the friend's status
                  
                    inMemoryFriends[index].status = .Confirmed
                }
            }
        }

    // Function to update/set an array in a user's document
    func updateDailyScores(uid: String, newScore: Int) async throws {
        if throwError {
            throw DBError.badDBResponse
        } else {
            for (index, user) in inMemoryUsers.enumerated() {
                // Search the user
                if user.id == uid {
                    var scoresArray = user.dailyScores
                    let today = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
                    scoresArray[today] = newScore
                    let scoresInRange = scoresArray[0...today]
                    scoresArray[7] = scoresInRange.reduce(0, +)
                    
                    // Simulate the delay in updating
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                    
                    // Update the local variable
                    inMemoryUsers[index].dailyScores = scoresArray
                }
            }
        }
    }
    
    func persistimageToStorage(image: UIImage?, completionBlock: @escaping (Result<String, Error>) -> Void) {
        if throwError {
            completionBlock(.failure(DBError.badDBResponse))
        } else {
            completionBlock(.success("fakeUrl"))
        }
    }
    
    
    // Fuction to delete user's document
    func deleteUserData(uid: String, friendsSubcollection: [Friend]) async throws {
        if throwError{
            throw DBError.badDBResponse
        } else {
            // Simulate the delay in deleting
            try await Task.sleep(nanoseconds: 3_000_000_000)
            
            inMemoryUsers.removeAll { $0.id == uid }
        }
    }
    
}

