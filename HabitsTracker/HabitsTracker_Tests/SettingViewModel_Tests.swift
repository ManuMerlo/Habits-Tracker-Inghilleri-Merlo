
import XCTest
import UserNotifications
@testable import HabitsTracker

@MainActor
class SettingsViewModelTests: XCTestCase {
    var viewModel: SettingsViewModel?
    
    override func setUp() {
        super.setUp()
        viewModel = SettingsViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func test_SirestoreViewModel_init_doesSetValuesCorrectly() {
        // Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        //When
        
        //Then
    
        XCTAssertFalse(vm.dailyNotification)
        XCTAssertFalse(vm.weeklyNotification)
    }
    
    
    func testScheduleNotifications() {
        //Given
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        let mockNotificationCenter = MockUserNotificationCenter()
        
        //When
        let title = "TestTitle"
        let subtitle = "TestSubtitle"
        let timeInterval: TimeInterval = 10
        let repeats = false
        
        let identifier = vm.scheduleNotifications(title: title, subtitle: subtitle, timeInterval: timeInterval, repeats: repeats, notificationCenter: mockNotificationCenter)
        
        //then
        XCTAssertNotNil(identifier, "Identifier should not be nil")
        XCTAssertEqual(mockNotificationCenter.addedRequest?.content.title, title, "Titles do not match")
        XCTAssertEqual(mockNotificationCenter.addedRequest?.content.subtitle, subtitle, "Subtitles do not match")
        XCTAssertNotNil(mockNotificationCenter.addedRequest?.trigger as? UNTimeIntervalNotificationTrigger, "Trigger type is incorrect")
        XCTAssertEqual((mockNotificationCenter.addedRequest?.trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval, timeInterval, "Time intervals do not match")
    }
    
    
    func test_SettingsViewModel_DateToStringConversion() {
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        let testDate = Date(timeIntervalSince1970: 1609459200) // Jan 1, 2021, 00:00:00 GMT
        let dateString = vm.dateToString(testDate)
        XCTAssertEqual(dateString, "01/01/2021", "Date to string conversion failed.")
    }
    
    func test_SettingsViewModel_StringToDateConversion() {
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        let testString = "01/01/2021"
        let date = vm.stringToDate(testString)
        let expectedDate = Date(timeIntervalSince1970: 1609459200) // Jan 1, 2021, 00:00:00 GMT
        XCTAssertEqual(date, expectedDate, "String to date conversion failed.")
    }
    
}
