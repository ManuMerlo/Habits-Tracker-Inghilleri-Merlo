import Foundation

import XCTest
@testable import HabitsTracker

class LeaderBoardViewModelTests: XCTestCase {
    
    var viewModel: LeaderBoardViewModel?
    
    override func setUp() {
        super.setUp()
        viewModel = LeaderBoardViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func test_LeaderBoardViewModel_SendPositionChangeNotification(){
        
        //Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        let mockNotificationCenter = MockUserNotificationCenter()
        
        //When
        vm.sendPositionChangeNotification(notificationCenter: mockNotificationCenter)
        
        //Then
        
        XCTAssertEqual(mockNotificationCenter.addedRequest?.content.title, "Ranking Position Change", "Titles do not match")
        XCTAssertEqual(mockNotificationCenter.addedRequest?.content.subtitle, "You are losing positions in the rankings! Hurry up!!", "Subtitles do not match")
        XCTAssertNotNil(mockNotificationCenter.addedRequest?.trigger as? UNTimeIntervalNotificationTrigger, "Trigger type is incorrect")
        XCTAssertEqual((mockNotificationCenter.addedRequest?.trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval, 20, "Time intervals do not match")
        
    }
    
    func test_LeaderBoardViewModel_SortUsersDaily() {
        //Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        // Create 3 users with random daily scores
        let user1 = User(
            id: UUID().uuidString,
            email: "user1@example.com",
            dailyScores: [190,214,502,633,447,265,162,2413]
        )

        let user2 = User(
            id: UUID().uuidString,
            email: "user2@example.com",
            dailyScores: [68,655,442,334,250,617,860,3226]
        )

        let user3 = User(
            id: UUID().uuidString,
            email: "user3@example.com",
            dailyScores: [123,527,234,789,133,675,987,3468]
        )
        
        let sortedUsers = vm.sortUsers(users: [user1,user2,user3], timeFrame: .daily)
        
        XCTAssertEqual(sortedUsers.first?.dailyScores[3], 789)
        XCTAssertEqual(sortedUsers.first?.email, "user3@example.com")
        
        
    }
    
    
    func test_LeaderBoardViewModel_SortUsersWeekly() {
        //Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        // Create 3 users with random daily scores
        let user1 = User(
            id: UUID().uuidString,
            email: "user1@example.com",
            dailyScores: [68,655,442,334,250,617,860,3226]
        )

        let user2 = User(
            id: UUID().uuidString,
            email: "user2@example.com",
            dailyScores: [190,214,502,633,447,265,162,2413]
        )

        let user3 = User(
            id: UUID().uuidString,
            email: "user3@example.com",
            dailyScores: [123,527,234,789,133,675,987,3468]
        )
        
        let sortedUsers = vm.sortUsers(users: [user1,user2,user3], timeFrame: .weekly)
        
        XCTAssertEqual(sortedUsers.first?.dailyScores[7], 3468)
        XCTAssertEqual(sortedUsers.first?.email, "user3@example.com")
    }
}

