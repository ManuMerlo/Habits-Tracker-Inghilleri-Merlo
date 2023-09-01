@testable import HabitsTracker

import Foundation
import SwiftUI
import HealthKit
import Combine

class MockHealthDataSource: HealthDataSourceProtocol{
    
    // Variables to control mock behavior
    var mockAccessResult: Result<Bool, Error>?
    var mockStats: [BaseActivity]?
    
    var publisher: PassthroughSubject<[BaseActivity], Never> = PassthroughSubject()
    
    // Default initializer
    init() {
        mockAccessResult = .success(true)
        mockStats = [
            BaseActivity(id: "activeEnergyBurned", quantity: Int.random(in: 0...500)),
            BaseActivity(id: "appleExerciseTime", quantity: Int.random(in: 0...200)),
            BaseActivity(id: "appleStandTime", quantity: Int.random(in: 0...24)),
            BaseActivity(id: "distanceWalkingRunning", quantity: Int.random(in: 0...30)),
            BaseActivity(id: "stepCount", quantity: Int.random(in: 0...30000)),
            BaseActivity(id: "distanceCycling", quantity: Int.random(in: 0...20))]
    }
    
    // Initializer with parameters
    init(mockAccessResult: Result<Bool, Error>?, mockStats: [BaseActivity]?) {
        self.mockAccessResult = mockAccessResult
        self.mockStats = mockStats
    }
    
    func getActivitiesPublisher() -> AnyPublisher<[BaseActivity], Never> {
            return publisher.eraseToAnyPublisher()
    }
    
    func requestAccessToHealthData(completion: @escaping (Result<Bool, Error>) -> Void) {
        if let result = mockAccessResult {
            completion(result)
        } else {
            completion(.failure(NSError(domain: "com.mock.error", code: 404, userInfo: ["message": "Mock not setup properly"])))
        }
    }
    
    func getTodayStats(by category: String){
        if let stats = mockStats {
            publisher.send(stats)
        }
    }
    
}

