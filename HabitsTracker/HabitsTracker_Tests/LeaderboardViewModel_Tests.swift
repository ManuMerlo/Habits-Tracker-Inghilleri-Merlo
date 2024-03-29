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
        let today = (Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
        switch today {
        case 0:
            XCTAssertEqual(sortedUsers.first?.dailyScores[0],190)
            XCTAssertEqual(sortedUsers.first?.email, "user1@example.com")
        case 1:
            XCTAssertEqual(sortedUsers.first?.dailyScores[1],655)
            XCTAssertEqual(sortedUsers.first?.email, "user2@example.com")
        case 2:
            XCTAssertEqual(sortedUsers.first?.dailyScores[2],502)
            XCTAssertEqual(sortedUsers.first?.email, "user1@example.com")
        case 3:
            XCTAssertEqual(sortedUsers.first?.dailyScores[3],789)
            XCTAssertEqual(sortedUsers.first?.email, "user3@example.com")
        case 4:
            XCTAssertEqual(sortedUsers.first?.dailyScores[4],447)
            XCTAssertEqual(sortedUsers.first?.email, "user1@example.com")
        case 5:
            XCTAssertEqual(sortedUsers.first?.dailyScores[5],675)
            XCTAssertEqual(sortedUsers.first?.email, "user3@example.com")
        case 6:
            XCTAssertEqual(sortedUsers.first?.dailyScores[6],987)
            XCTAssertEqual(sortedUsers.first?.email, "user3@example.com")
        default:
            XCTFail()
        }
 
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

