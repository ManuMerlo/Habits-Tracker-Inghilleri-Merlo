
import XCTest
import UserNotifications
@testable import HabitsTracker

@MainActor
class SettingsViewModelTests: XCTestCase {
    
    var viewModel: SettingsViewModel?
    var mockNotificationCenter : MockUserNotificationCenter?
    
    override func setUp() {
        super.setUp()
        mockNotificationCenter = MockUserNotificationCenter()
        viewModel = SettingsViewModel(notificationCenter: mockNotificationCenter)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNotificationCenter = nil
        super.tearDown()
    }
    
    func test_SirestoreViewModel_init_doesSetValuesCorrectly() {
        // Given
        let vm = SettingsViewModel()
        
        XCTAssertEqual(vm.dailyNotificationIdentifier,"")
        XCTAssertEqual(vm.weeklyNotificationIdentifier,"")
        XCTAssertFalse(vm.notificationPermissionGranted)
        XCTAssertFalse(vm.settingsNotifications)
        XCTAssertNil(vm.image)
        XCTAssertFalse(vm.dailyNotification)
        XCTAssertFalse(vm.weeklyNotification)
    }
    
    
    func test_SettingsViewModel_ScheduleNotifications() {
        //Given
        guard let vm = viewModel, let mockNotificationCenter = mockNotificationCenter else {
            XCTFail()
            return
        }

        //When
        let title = "TestTitle"
        let subtitle = "TestSubtitle"
        let timeInterval: TimeInterval = 10
        let repeats = false
        
        let identifier = vm.scheduleNotifications(title: title, subtitle: subtitle, timeInterval: timeInterval, repeats: repeats)
        
        //then
        XCTAssertNotNil(identifier, "Identifier should not be nil")
        XCTAssertEqual(mockNotificationCenter.addedRequests.last?.content.title, title, "Titles do not match")
        XCTAssertEqual(mockNotificationCenter.addedRequests.last?.content.subtitle, subtitle, "Subtitles do not match")
        XCTAssertNotNil(mockNotificationCenter.addedRequests.last?.trigger as? UNTimeIntervalNotificationTrigger, "Trigger type is incorrect")
        XCTAssertEqual((mockNotificationCenter.addedRequests.last?.trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval, timeInterval, "Time intervals do not match")
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
    
    
    func test_SettingsViewModel_saveNotificationPermission_stressTest() {
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        let range = Range(0...10)
        for _ in range {
            let bool = Bool.random()
            vm.saveNotificationPermission(value: bool)
            XCTAssertEqual(vm.notificationPermissionGranted, bool)
        }
    }
    
    func test_SettingsViewModel_startDailyNotifications() {
        guard let vm = viewModel, let mockNotificationCenter = mockNotificationCenter else {
            XCTFail()
            return
        }
        
        vm.startDailyNotifications()
        XCTAssertEqual(vm.dailyNotificationIdentifier, mockNotificationCenter.addedRequests.last?.identifier)
        
        XCTAssertEqual(mockNotificationCenter.addedRequests.last?.content.title, "Daily Notification", "Titles do not match")
        XCTAssertEqual(mockNotificationCenter.addedRequests.last?.content.subtitle,"You are doing great!!", "SubTitles do not match")
        XCTAssertNotNil(mockNotificationCenter.addedRequests.last?.trigger as? UNTimeIntervalNotificationTrigger, "Trigger type is incorrect")
        XCTAssertEqual((mockNotificationCenter.addedRequests.last?.trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval, 86400, "Time intervals do not match")
    }
    
    func test_SettingsViewModel_stopDailyNotification() {
        guard let vm = viewModel, let mockNotificationCenter = mockNotificationCenter else {
            XCTFail()
            return
        }
        
        vm.startDailyNotifications()
        
        XCTAssertEqual(vm.dailyNotificationIdentifier, mockNotificationCenter.addedRequests.last?.identifier)
        
        vm.stopDailyNotifications()
        
        XCTAssertEqual(vm.dailyNotificationIdentifier, nil)
    }
    
    func test_SettingsViewModel_stopWeeklyNotification() {
        guard let vm = viewModel, let mockNotificationCenter = mockNotificationCenter else {
            XCTFail()
            return
        }
        
        vm.startWeeklyNotifications()
        
        XCTAssertEqual(vm.weeklyNotificationIdentifier, mockNotificationCenter.addedRequests.last?.identifier)
        
        vm.stopWeeklyNotifications()
        
        XCTAssertEqual(vm.weeklyNotificationIdentifier, nil)
    }
    
    func test_SettingsViewModel_startWeeklyNotifications() {
        guard let vm = viewModel, let mockNotificationCenter = mockNotificationCenter else {
            XCTFail()
            return
        }
        
        vm.startWeeklyNotifications()
        XCTAssertEqual(vm.weeklyNotificationIdentifier, mockNotificationCenter.addedRequests.last?.identifier)
        
        XCTAssertEqual(mockNotificationCenter.addedRequests.last?.content.title, "Weekly Notification", "Titles do not match")
        XCTAssertEqual(mockNotificationCenter.addedRequests.last?.content.subtitle,"You are doing great!!", "SubTitles do not match")
        XCTAssertNotNil(mockNotificationCenter.addedRequests.last?.trigger as? UNTimeIntervalNotificationTrigger, "Trigger type is incorrect")
        XCTAssertEqual((mockNotificationCenter.addedRequests.last?.trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval, 86400*7, "Time intervals do not match")
    }
    
}
