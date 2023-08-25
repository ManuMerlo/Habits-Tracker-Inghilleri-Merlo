import XCTest
@testable import HabitsTracker

@MainActor
final class AuthenticationViewModel_Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_AuthenticationViewModel_showAlert_shouldBeFalse() {
        // Given
        
        // When
        let authenticationViewModel = AuthenticationViewModel()
        // Then
        XCTAssertFalse(authenticationViewModel.showAlert)
    }

}
