import Foundation
import SwiftUI
import Combine

final class HealthRepository : ObservableObject {
    
    private var cancellables: Set<AnyCancellable> = []
    
    var healthDataSource: HealthDataSourceProtocol
    
    init(healthDataSource: HealthDataSourceProtocol = HealthDataSource()) {
        self.healthDataSource = healthDataSource
    }
       
    //Second initializer for test purposes
    init(withDataSource healthDataSource: HealthDataSourceProtocol) {
        self.healthDataSource = healthDataSource
    }
    
    func getActivitiesPublisher() -> AnyPublisher<[BaseActivity], Never> {
           return healthDataSource.getActivitiesPublisher()
    }
    
    func requestAccessToHealthData(completion: @escaping (Result<Bool, Error>) -> Void) {
        healthDataSource.requestAccessToHealthData(completion: completion)
    }
    
    func getTodayStats(by category: String) {
        healthDataSource.getTodayStats(by: category)
    }
    
}
