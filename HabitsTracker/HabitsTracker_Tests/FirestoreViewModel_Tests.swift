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
        let mockDataSource = MockFirestoreDataSource()
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        // When
        
        // Then
        XCTAssertNil(vm.firestoreUser)
        XCTAssertFalse(vm.needUsername)
        XCTAssertEqual(vm.requests, [])
        XCTAssertEqual(vm.tasks,[])
        XCTAssertEqual(vm.friendsSubcollection, [])
    }
    
    func test_FirestoreViewModel_addListenerForCurrentUser_noNeedUsername(){
        // Given
        let mockDataSource = MockFirestoreDataSource()
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When
        vm.addListenerForCurrentUser { error in
            if let _ = error {
                XCTFail()
            } else {
                // Then
                XCTAssertNotNil(vm.firestoreUser)
                XCTAssertEqual(vm.firestoreUser?.id, "1")
                XCTAssertEqual(vm.firestoreUser?.email, "john.doe@example.com")
                XCTAssertFalse(vm.needUsername)
            }
        }
    }
    
    func test_FirestoreViewModel_addListenerForCurrentUser_needUsername(){
        // Given
        let id = UUID().uuidString
        let currentUser = User(id: id, email: "example@email.com")
        let mockDataSource = MockFirestoreDataSource(users: [currentUser])
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When
        vm.addListenerForCurrentUser { error in
            if let _ = error {
                XCTFail()
            } else {
                // Then
                XCTAssertNotNil(vm.firestoreUser)
                XCTAssertEqual(vm.firestoreUser?.id, id)
                XCTAssertEqual(vm.firestoreUser?.email, "example@email.com")
                XCTAssertTrue(vm.needUsername)
            }
        }
    }
    
    func test_FirestoreViewModel_addListenerForCurrentUser_ErrorUserRetrieval(){
        // Given
        let mockDataSource = MockFirestoreDataSource(users: [])
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When
        vm.addListenerForCurrentUser { error in
            guard let error = error as? DBError, error == .failedUserRetrieval else {
                XCTFail()
                return
            }
            XCTAssertEqual(vm.messageError, DBError.failedUserRetrieval.description)
            XCTAssertFalse(vm.needUsername)
            XCTAssertNil(vm.firestoreUser)
        }
    }
    
    func test_FirestoreViewModel_fieldIsPresent_shouldBeTrue() async {
        //Given
        let mockDataSource = MockFirestoreDataSource()
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
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
        //Given
        let mockDataSource = MockFirestoreDataSource()
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        let field = "email"
        let value = "nonexistentemail@example.com"  //this value doesn't exist in the 'Users' JSON.
        
        do {
               let result = try await vm.fieldIsPresent(field: field, value: value)
               XCTAssertFalse(result)
           } catch {
               XCTFail("Error: \(error)")
           }
       }
    
    func test_FirestoreViewModel_fieldIsPresent_shouldThrowError() async {
        //Given
        let mockDataSource = MockFirestoreDataSource(throwError: true)
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        let field = "email"
        let value = "nonexistentemail@example.com"  //this value doesn't exist in the 'Users' JSON.
        
        do {
            let _ = try await vm.fieldIsPresent(field: field, value: value)
            XCTFail()
           } catch {
               if let error = error as? DBError{
                   XCTAssertEqual(error, DBError.badDBResponse)
               }
           }
       }

    
    func test_FirestoreViewModel_fieldIsPresent_injectedValue_stress() async {
        //Given
        let mockDataSource = MockFirestoreDataSource()
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
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
        // Given : be sure that no other tests modify the mock
        let mockDataSource = MockFirestoreDataSource()
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
        
        // Then
        wait(for: [expectation], timeout: 5)
        
        XCTAssertNotNil(vm.friendsSubcollection)
    }
    
    func test_FirestoreViewModel_getRequests_withNotEmptyRequestsIds() async {
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
        let expectation = XCTestExpectation(description: "Should return friendsSubcollection after 3 seconds.")
        
        //Retrieve firends
        vm.$friendsSubcollection
            .dropFirst()
            .sink { returnedList in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.addListenerForFriendsSubcollection()
        
        // Then
        await fulfillment(of: [expectation], timeout: 5)
        
        XCTAssertEqual(vm.friendsSubcollection, friendsArray)

        vm.getRequests()
        
        let task_request = vm.tasks.last
        let _ = await task_request?.result

        // Then
   
        XCTAssertEqual(vm.requests, usersArray)
    }
    
    func test_FirestoreViewModel_getRequests_withFailure() async {
        // Given : simulate right environment
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
        
        //Make the mock thorugh a DBError
        let mockDataSource = MockFirestoreDataSource(users : usersArray, friends: friendsArray,throwError: true)
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
        
        // Then
        await fulfillment(of: [expectation], timeout: 5, enforceOrder: false)
        
        XCTAssertEqual(vm.friendsSubcollection, friendsArray)

        vm.getRequests()
        
        let task_request = vm.tasks.last
        let _ = await task_request?.result

        // Then
        XCTAssertEqual(vm.requests,[])
        XCTAssertEqual(vm.messageError, DBError.badDBResponse.description)
        
    }
    
    func test_FirestoreViewModel_modifyUser_withSuccess() async {
        // Given
        let mockDataSource = MockFirestoreDataSource()
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        //When
        vm.modifyUser(uid: "1", field: "email", value: "test@test.com")
        
        let task_request = vm.tasks.last
        let _ = await task_request?.result
        
        vm.addListenerForCurrentUser { error in
            if let _ = error {
                XCTFail()
            } else {
                XCTAssertEqual(vm.firestoreUser?.email, "test@test.com")
                XCTAssertNil(vm.messageError)
            }
        }
        
    }
    
    func test_FirestoreViewModel_modifyUser_withFailure() async {
        // Given
        let mockDataSource = MockFirestoreDataSource(throwError: true)
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        //When
        vm.modifyUser(uid: "1", field: "email", value: "test@test.com")
        
        let task_request = vm.tasks.last
        let _ = await task_request?.result
        
        vm.addListenerForCurrentUser { error in
            if let _ = error {
                XCTFail()
            } else {
                XCTAssertEqual(vm.firestoreUser?.email, "john.doe@example.com")
                XCTAssertEqual(vm.messageError, DBError.badDBResponse.description)
            }
        }
        
    }
    
    func test_FirestoreViewModel_modifyUserRecord_withSuccess() async {
        // Given
        let mockDataSource = MockFirestoreDataSource()
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        //When
        let records: [BaseActivity] = [
            BaseActivity(id:"activeEnergyBurned", quantity: 400),
            BaseActivity(id:"appleExerciseTime", quantity: 65),
            BaseActivity(id:"appleStandTime", quantity: 23),
            BaseActivity(id:"distanceWalkingRunning", quantity: 320),
            BaseActivity(id:"stepCount", quantity: 3456),
            BaseActivity(id:"distanceCycling", quantity: 12)
        ]
        
        vm.modifyUser(uid: "1", field: "records", records: records)
        
        let task_request = vm.tasks.last
        let _ = await task_request?.result
        
        vm.addListenerForCurrentUser { error in
            if let _ = error {
                XCTFail()
            } else {
                XCTAssertEqual(vm.firestoreUser?.records, records)
                XCTAssertEqual(vm.messageError, nil)
            }
        }
    }
    
    func test_FirestoreViewModel_addRequest_withSuccess() async {
        //Given : no friends
        let mockDataSource = MockFirestoreDataSource(friends: [])
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When : add a user in .Waiting status
        vm.addRequest(uid: "1", friendId: "2")
        
        let task_addRequest = vm.tasks.last
        let _ = await task_addRequest?.result
        
        let expectation = XCTestExpectation(description: "Should return friendsSubcollection after 3 seconds.")
        
        vm.$friendsSubcollection
            .dropFirst()
            .sink { returnedList in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.addListenerForFriendsSubcollection()
        
        // Then
        await fulfillment(of: [expectation], timeout: 5, enforceOrder: false)
        
        let result = vm.getFriendStatus(friendId: "2")
        
        XCTAssertEqual(result, .Waiting)
        XCTAssertEqual(vm.friendsSubcollection.count, 1)
    }
    
    
    func test_FirestoreViewModel_addRequest_withFailure() async {
        //Given : no friends, with error
        let mockDataSource = MockFirestoreDataSource(friends: [],throwError: true)
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When : try to add request
        vm.addRequest(uid: "1", friendId: "2")
        
        let task_addRequest = vm.tasks.last
        let _ = await task_addRequest?.result
        
        let expectation = XCTestExpectation(description: "Should return friendsSubcollection after 3 seconds.")
        
        vm.$friendsSubcollection
            .dropFirst()
            .sink { returnedList in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.addListenerForFriendsSubcollection()
        
        // Then
        await fulfillment(of: [expectation], timeout: 5, enforceOrder: false)
        
        let result = vm.getFriendStatus(friendId: "2")
        
        XCTAssertEqual(result,nil)
        XCTAssertEqual(vm.friendsSubcollection.count, 0)
        XCTAssertEqual(vm.messageError, DBError.badDBResponse.description)
    }
    
    func test_FirestoreViewModel_removeFriend_withSuccess() async {
        // Given: 1 friends in .Confirmed status
        let friend : Friend = Friend(id: "2", status: .Confirmed)
        let mockDataSource = MockFirestoreDataSource(friends: [friend])
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When
        vm.removeFriend(uid: "1", friendId:"2")
        
        let task_removeFriend = vm.tasks.last
        let _ = await task_removeFriend?.result
        
        let expectation = XCTestExpectation(description: "Should return friendsSubcollection after 3 seconds.")
        
        vm.$friendsSubcollection
            .dropFirst()
            .sink { returnedList in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.addListenerForFriendsSubcollection()
        
        // Then
        await fulfillment(of: [expectation], timeout: 5, enforceOrder: false)
        
        XCTAssertEqual(vm.friendsSubcollection,[])
    }
    
    func test_FirestoreViewModel_removeFriend_withFailure() async {
        // Given: 1 friends in .Confirmed status
        let friend : Friend = Friend(id: "2", status: .Confirmed)
        let mockDataSource = MockFirestoreDataSource(friends: [friend],throwError: true)
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When
        vm.removeFriend(uid: "1", friendId:"2")
        
        let task_removeFriend = vm.tasks.last
        let _ = await task_removeFriend?.result
        
        let expectation = XCTestExpectation(description: "Should return friendsSubcollection after 3 seconds.")
        
        vm.$friendsSubcollection
            .dropFirst()
            .sink { returnedList in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.addListenerForFriendsSubcollection()
        
        // Then
        await fulfillment(of: [expectation], timeout: 5, enforceOrder: false)
        
        XCTAssertEqual(vm.friendsSubcollection.count, 1)
        XCTAssertEqual(vm.getFriendStatus(friendId: "2"), .Confirmed)
        XCTAssertEqual(vm.messageError, DBError.badDBResponse.description)
    }
    
    func test_FirestoreViewModel_confirmFriend_withSuccess() async {
        // Given: 1 friends in .Request status
        let friend : Friend = Friend(id: "2", status: .Request)
        let mockDataSource = MockFirestoreDataSource(friends: [friend],throwError: false)
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When
        vm.confirmFriend(uid: "1", friendId: "2")
        
        let task_confirmFriend = vm.tasks.last
        let _ = await task_confirmFriend?.result
        
        let expectation = XCTestExpectation(description: "Should return friendsSubcollection after 3 seconds.")
        
        vm.$friendsSubcollection
            .dropFirst()
            .sink { returnedList in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.addListenerForFriendsSubcollection()
        
        // Then
        await fulfillment(of: [expectation], timeout: 5, enforceOrder: false)
        
        let result = vm.getFriendStatus(friendId: "2")
        
        XCTAssertEqual(vm.friendsSubcollection.count, 1)
        XCTAssertEqual(result, .Confirmed)
    }
    
    func test_FirestoreViewModel_confirmFriend_withFailure() async {
        //Given: 1 request and the data source that throw an error
        let friend : Friend = Friend(id: "2", status: .Request)
        let mockDataSource = MockFirestoreDataSource(friends: [friend],throwError: true)
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When
        vm.confirmFriend(uid: "1", friendId: "2")
        
        let task_confirmFriend = vm.tasks.last
        let _ = await task_confirmFriend?.result
        
        let expectation = XCTestExpectation(description: "Should return friendsSubcollection after 3 seconds.")
        
        vm.$friendsSubcollection
            .dropFirst()
            .sink { returnedList in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.addListenerForFriendsSubcollection()
        
        // Then
        await fulfillment(of: [expectation], timeout: 5, enforceOrder: false)
        
        let result = vm.getFriendStatus(friendId: "2")
        
        XCTAssertEqual(vm.friendsSubcollection.count, 1)
        XCTAssertEqual(result, .Request)
        XCTAssertEqual(vm.messageError, DBError.badDBResponse.description)
    }
    
    func test_FirestoreViewModel_updateDailyScore_withSuccess() async {
        // Given
        let mockDataSource = MockFirestoreDataSource(throwError: false)
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When
        let newScore = Int.random(in: 0...300)
        let today = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
        vm.updateDailyScores(uid: "1", newScore: newScore)
        
        let task_updateScore = vm.tasks.last
        let _ = await task_updateScore?.result

        vm.addListenerForCurrentUser { error in
            if let _ = error {
                XCTFail()
            } else {
                // Then
                XCTAssertEqual(vm.firestoreUser?.dailyScores[today],newScore)
            }
        }
 
    }
    
    func test_FirestoreViewModel_updateDailyScore_withFailure() async {
        // Given
        let mockDataSource = MockFirestoreDataSource(throwError: true)
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When
        let oldScores = [10, 15, 12, 20, 14, 22, 13, 106]
        let newScore = 23
        let today = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
        vm.updateDailyScores(uid: "1", newScore: newScore)
        
        let task_updateScore = vm.tasks.last
        let _ = await task_updateScore?.result
        
        vm.addListenerForCurrentUser { error in
            if let _ = error {
                XCTFail()
            } else {
                // Then
                XCTAssertEqual(vm.firestoreUser?.dailyScores[today],oldScores[today])
                XCTAssertEqual(vm.messageError, DBError.badDBResponse.description)
            }
        }
    }
    
    func test_FirestoreViewModel_deleteUserData_withSuccess() async {
        // Given
        let user = User(id: "testId", email: "test@test.com")
        let mockDataSource = MockFirestoreDataSource(users: [user], throwError: false)
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        /// When
        do {
            
            try await vm.deleteUserData(uid: "testId")

            vm.addListenerForCurrentUser { error in
                if let _ = error {
                    XCTAssertNil(vm.firestoreUser)
                } else {
                    XCTFail()
                }
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_FirestoreViewModel_deleteUserData_withFailure() async {
        // Given
        let user = User(id: "testId", email: "test@test.com")
        let mockDataSource = MockFirestoreDataSource(users: [user], throwError: true)
        let vm = FirestoreViewModel(firestoreRepository: FirestoreRepository(withDataSource: mockDataSource))
        
        // When
        do {
            try await vm.deleteUserData(uid: "testId")
            XCTFail("Expected to throw DBError.badDBResponse, but it did not.")
        } catch {
            // Ensure the thrown error is the one we expect
            XCTAssertEqual(error as? DBError, DBError.badDBResponse)
        }

        vm.addListenerForCurrentUser { error in
            if let _ = error {
                XCTFail()
            } else {
                // Then
                XCTAssertNotNil(vm.firestoreUser)
                XCTAssertEqual(vm.firestoreUser?.id, "testId")
                XCTAssertEqual(vm.firestoreUser?.email, "test@test.com")
            }
        }
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

