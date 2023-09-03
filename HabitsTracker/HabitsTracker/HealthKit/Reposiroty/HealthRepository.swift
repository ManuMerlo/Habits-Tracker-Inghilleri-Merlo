import Foundation
import SwiftUI
import Combine

final class HealthRepository : ObservableObject {
    
    private var cancellables: Set<AnyCancellable> = []
    
    var healthDataSource: HealthDataSourceProtocol
    
    /// Initializes a new instance of the `HealthRepository` with the default `HealthDataSource`.
    /// - Parameter healthDataSource: An optional data source. Defaults to `HealthDataSource()`.
    init(healthDataSource: HealthDataSourceProtocol = HealthDataSource()) {
        self.healthDataSource = healthDataSource
    }
       
    /// Alternative initializer, mainly for testing purposes.
    /// - Parameter healthDataSource: The data source used to fetch health data.
    init(withDataSource healthDataSource: HealthDataSourceProtocol) {
        self.healthDataSource = healthDataSource
    }
    
    /// Get a publisher for health activities.
    /// - Returns: A publisher that emits a list of `BaseActivity` items.
    func getActivitiesPublisher() -> AnyPublisher<[BaseActivity], Never> {
           return healthDataSource.getActivitiesPublisher()
    }
    
    /// Request access to specific health data types.
    /// - Parameter completion: Callback containing the result of the request.
    func requestAccessToHealthData(completion: @escaping (Result<Bool, Error>) -> Void) {
        healthDataSource.requestAccessToHealthData(completion: completion)
    }
    
    /// Fetch the statistics of a specific health data type for today.
    /// - Parameter category: The health data type category as a string.
    func getTodayStats(by category: String) {
        healthDataSource.getTodayStats(by: category)
    }
    
}
