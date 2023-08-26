// Naming Structure: test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct or class]_[variable or function]_[expected result]
// Testing Structure: Given, When, Then


@testable import HabitsTracker

import XCTest
import Foundation
import Combine

@MainActor
final class FirestoreViewModelTests: XCTestCase, Mockable {
    var viewModel: FirestoreViewModel?
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        super.setUp()
        let mockDataSource = MockFirestoreDataSource()
        viewModel = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        super.tearDown()
    }
    
    func test_FirestoreViewModel_init_doesSetValuesCorrectly() {
        // Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        // When
        
        // Then
        XCTAssertNil(vm.firestoreUser)
        XCTAssertFalse(vm.needUsername)
        XCTAssertEqual(vm.requests, [])
        XCTAssertEqual(vm.tasks,[])
        XCTAssertEqual(vm.friendsSubcollection, [])
    }
    
    func test_FirestoreViewModel_cancelTasks_tasksShouldBeEmpty() {
        // Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        //This should add a task to the tasks array
        vm.getRequests()
        
        // The tasks array should not be empty
        XCTAssertFalse(vm.tasks.isEmpty, "Tasks array should not be empty after adding a new user")
        
        // When
        vm.cancelTasks()
        
        // Then
        // Tasks should be canceled and the tasks array should be empty after calling cancelTasks
        XCTAssertTrue(vm.tasks.isEmpty, "Tasks array should be empty after cancellation")
    }
    
    func test_FirestoreViewModel_addListenerForCurrentUser_noNeedUsername(){
        // Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        // When
        let expectation = XCTestExpectation(description: "Should return first user after 3 seconds.")
        
        vm.$firestoreUser
            .dropFirst()
            .sink { returnedUser in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.addListenerForCurrentUser()
        
        // Then
        wait(for: [expectation], timeout: 5)
        
        XCTAssertNotNil(vm.firestoreUser)
        XCTAssertFalse(vm.needUsername)
    }
    
    func test_FirestoreViewModel_addListenerForCurrentUser_needUsername(){
        // Given
        let currentUser = User(id: UUID().uuidString, email: "example@email.com")
        let mockDataSource = MockFirestoreDataSource(users: [currentUser])
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When
        let expectation = XCTestExpectation(description: "Should return first user after 3 seconds.")
        
        vm.$firestoreUser
            .dropFirst()
            .sink { returnedUser in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.addListenerForCurrentUser()
        
        // Then
        wait(for: [expectation], timeout: 5)
        
        XCTAssertNotNil(vm.firestoreUser)
        XCTAssertTrue(vm.needUsername)
    }
    
    func test_FirestoreViewModel_fieldIsPresent_shouldBeTrue() async {
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        let field = "email"
        let value = "john.doe@example.com"

        do {
            let result = try await vm.fieldIsPresent(field: field, value: value)
            XCTAssertTrue(result)
        } catch {
            XCTFail("Error: \(error)")
        }
        
       
    }

    
    func test_FirestoreViewModel_fieldIsPresent_shouldBeFalse() async {
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        let field = "email"
        let value = "nonexistentemail@example.com"  //this value doesn't exist in the 'Users' JSON.
        
        do {
               let result = try await vm.fieldIsPresent(field: field, value: value)
               XCTAssertFalse(result)
           } catch {
               XCTFail("Error: \(error)")
           }
       }

    
    func test_FirestoreViewModel_fieldIsPresent_injectedValue_stress() async {
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        let fields = ["id", "email", "username", "birthDate", "image", "sex", "height", "weight"]
        
        // Extract some known values from Users JSON.
        // The method `extractKnownValues(field: String) -> [String]` extracts an array of values for the given field .
        var knownValues: [String: [String]] = [:]
        for field in fields {
            knownValues[field] = extractKnownValues(field: field)
        }

            let randomField = fields.randomElement() ?? "id"
            
            // Decide whether to use a known value or a random UUID.
            let useKnownValue = Bool.random()
            let valueToQuery: String
            
            if useKnownValue, let knownValueForField = knownValues[randomField]?.randomElement() {
                valueToQuery = knownValueForField
            } else {
                valueToQuery = UUID().uuidString
            }

        
            do {
                let result = try await vm.fieldIsPresent(field: randomField, value: valueToQuery)
                if useKnownValue {
                    XCTAssertTrue(result, "Failed for known value \(valueToQuery) in field \(randomField)")
                }
                else {
                    XCTAssertFalse(result)
                }
            } catch {
                XCTFail("Error: \(error)")
            }
    }

    func extractKnownValues(field: String) -> [String] {
        let users = loadJSON(filename: "Users", type: User.self)
        
        var values: [String] = []

        for user in users {
            switch field {
            case "id":
                values.append(user.id)
            case "email":
                values.append(user.email)
            case "username":
                if let username = user.username {values.append(username)}
            case "birthDate":
                if let birthDate = user.birthDate {values.append(birthDate)}
               
            case "sex":
                if let sex = user.sex {
                    values.append(sex.rawValue)
                }
            case "height":
                if let height = user.height {
                    values.append("\(height)")
                }
            case "weight":
                if let weight = user.weight {
                    values.append("\(weight)")
                }
            case "image":
                if let image = user.image {values.append(image)}
            default:
                break
            }
        }
        
        return values
    }
    
    func test_FirestoreViewModel_addListenerForFriendsSubcollection_withSuccess(){
        // Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        // When
        let expectation = XCTestExpectation(description: "Should return friendsSubcollection after 3 seconds.")
        
        vm.$friendsSubcollection
            .dropFirst()
            .sink { returnedList in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.addListenerForFriendsSubcollection()
        
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertNotNil(vm.friendsSubcollection)
        XCTAssertEqual(vm.friendsSubcollection.count, 3)
    }
    
    func test_FirestoreViewModel_getRequests_withNotEmptyRequestsIds() {
        // Given
        let loopCount: Int = Int.random(in: 1..<100)
        
        var friendsArray: [Friend] = []
        var usersArray: [User] = []
        for _ in 0..<loopCount {
            let newFriendId = UUID().uuidString
            let newFriend = Friend(id: newFriendId, status: .Request)
            let newUser = User(id: newFriendId, email: "\(newFriendId)@fakedomain.com")
            friendsArray.append(newFriend)
            usersArray.append(newUser)
        }
        
        let mockDataSource = MockFirestoreDataSource(users : usersArray, friends: friendsArray)
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))

        // When
        let expectation1 = XCTestExpectation(description: "Should return friendsSubcollection after a delay.")
        vm.$friendsSubcollection
            .dropFirst()
            .sink { returnedList in
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        vm.addListenerForFriendsSubcollection()
        wait(for: [expectation1], timeout: 5)
        
        XCTAssertEqual(vm.friendsSubcollection, friendsArray)
        
        let expectation2 = XCTestExpectation(description: "Should return requests after a delay.")
        vm.$requests
            .dropFirst()
            .sink { returnedList in
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        vm.getRequests()
        wait(for: [expectation2], timeout: 10)
            
        // Then
        XCTAssertNotEqual(vm.requests, [])
        XCTAssertEqual(vm.requests.count, friendsArray.count)
        XCTAssertGreaterThan(vm.tasks.count, 0)
    }

    func test_FirestoreViewModel_modifyUser_shouldModify() async {
        // Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }

        // When
        let newValue = "example@gmail.com"

        // Create a Task and directly await it
        let task = Task {
            vm.modifyUser(uid: "1", field: "email", value: newValue)
        }
        
        await task.value
        
        let expectation = XCTestExpectation(description: "Should return first user after 3 seconds.")

        vm.$firestoreUser
            .dropFirst()
            .sink { returnedUser in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        vm.addListenerForCurrentUser()

        // Then
        await fulfillment(of: [expectation], timeout: 5) // Replaced the traditional wait(for:timeout:) method

        XCTAssertEqual(vm.firestoreUser?.email, newValue)
    }

    

    
    func test_FirestoreViewModel_getFriendStatus_injectedValues_shouldSuccess(){
        //Given
        let loopCount: Int = Int.random(in: 1..<100)
        var friendsArray: [Friend] = []
        let friendStatuses: [FriendStatus] = [.Waiting, .Confirmed, .Request]
        
        for _ in 0..<loopCount {
            let newFriendId = UUID().uuidString
            let randomStatus = friendStatuses.randomElement() ?? .Waiting
            let newFriend = Friend(id: newFriendId, status: randomStatus)
            friendsArray.append(newFriend)
        }
        
        let mockDataSource = MockFirestoreDataSource(friends: friendsArray)
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When
        let expectation = XCTestExpectation(description: "Should return friendsSubcollection after 3 seconds.")
        
        vm.$friendsSubcollection
            .dropFirst()
            .sink { returnedList in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.addListenerForFriendsSubcollection()
        
        wait(for: [expectation], timeout: 5)
        
        for _ in 0..<10 {
            let randomIndex = Int.random(in: 0..<friendsArray.count)
            let result = vm.getFriendStatus(friendId: friendsArray[randomIndex].id)
            XCTAssertEqual(result, friendsArray[randomIndex].status)
        }
        
    }
    
    func test_FirestoreViewModel_getFriendsIdsWithStatus_injectedValues_injectedValues_shouldSuccess() {
        //Given
        let loopCount: Int = Int.random(in: 1..<100)
        var waitingList: [String] = []
        var friendList: [String] = []
        var requestList: [String] = []
        
        var friendsArray: [Friend] = []
        
        for _ in 0..<loopCount {
            let newFriendId = UUID().uuidString
            let friendStatuses: [FriendStatus] = [.Waiting, .Confirmed]
            let randomStatus = friendStatuses.randomElement() ?? .Waiting
            
            let newFriend = Friend(id: newFriendId, status: randomStatus)
           
            friendsArray.append(newFriend)
            
            switch randomStatus {
            case .Waiting:
                waitingList.append(newFriendId)
            case .Confirmed:
                friendList.append(newFriendId)
            case .Request:
                requestList.append(newFriendId)
            }
            
        }
        
        let mockDataSource = MockFirestoreDataSource(friends: friendsArray)
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))

        //When
        
        let expectation = XCTestExpectation(description: "Should return friendsSubcollection after 3 seconds.")
        var cancellables = Set<AnyCancellable>()
        
        vm.$friendsSubcollection
            .dropFirst()
            .first()  // Capture only the first update
            .sink(receiveCompletion: { _ in
                // This block captures the completion, either due to success or failure.
                expectation.fulfill()
            }, receiveValue: { _ in
                // This block captures each update to the value.
            })
            .store(in: &cancellables)
        
        vm.addListenerForFriendsSubcollection()
        wait(for: [expectation], timeout: 5)
        
        // Test for each status
        let waitingResult = vm.getFriendsIdsWithStatus(status: .Waiting)
        XCTAssertEqual(waitingResult.sorted(), waitingList.sorted())
        
        let friendResult = vm.getFriendsIdsWithStatus(status: .Confirmed)
        XCTAssertEqual(friendResult.sorted(), friendList.sorted())
        
        let requestResult = vm.getFriendsIdsWithStatus(status: .Request)
        XCTAssertEqual(requestResult.sorted(), requestList.sorted())

    }
    
    func test_FirestoreViewModel_getRequests_withEmpyRequestsIds(){
        // Given
        let mockDataSource = MockFirestoreDataSource(friends: [])
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When
        let expectation = XCTestExpectation(description: "Should return friendsSubcollection after 3 seconds.")
        let expectation2 = XCTestExpectation(description: "Should return empty list after 3 seconds.")
        
        vm.$friendsSubcollection
            .dropFirst()
            .sink { returnedList in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.addListenerForFriendsSubcollection()
        
        // Then
        wait(for: [expectation], timeout: 5)
        
        vm.$requests
            .dropFirst()
            .sink { returnedList in
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        vm.getRequests()
        
        wait(for: [expectation2], timeout: 5)
        
        XCTAssertEqual(vm.requests, [])
        XCTAssertEqual(vm.requests.count, 0)
        XCTAssertGreaterThan(vm.tasks.count, 0)
        
    }

}

