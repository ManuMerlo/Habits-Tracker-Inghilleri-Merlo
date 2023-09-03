import Foundation
import HealthKit
import SwiftUI
import Combine

/// Protocol to define essential methods for health data access.
protocol HealthDataSourceProtocol {
    
    /// Request access to specific health data types.
    /// - Parameter completion: Callback containing the result of the request.
    func requestAccessToHealthData(completion: @escaping (Result<Bool, Error>) -> Void)
    
    /// Fetch the statistics of a specific health data type for today.
    /// - Parameter category: The health data type category as a string.
    func getTodayStats(by category: String)
    
    /// Get a publisher for activities.
    /// - Returns: A publisher for a list of `BaseActivity` items.
    func getActivitiesPublisher() -> AnyPublisher<[BaseActivity], Never>
}

final class HealthDataSource : HealthDataSourceProtocol, ObservableObject {
    
    private let healthStore: HKHealthStore = HKHealthStore()
    private var observerQuery: HKObserverQuery?
    private var query: HKStatisticsQuery?
    
    private var allMyTypes: [BaseActivity] = [
        BaseActivity(id: "activeEnergyBurned", quantity: 0),
        BaseActivity(id: "appleExerciseTime", quantity: 0),
        BaseActivity(id: "appleStandTime", quantity: 0),
        BaseActivity(id: "distanceWalkingRunning", quantity: 0),
        BaseActivity(id: "stepCount", quantity: 0),
        BaseActivity(id: "distanceCycling", quantity: 0),
    ]
    
    var publisher: PassthroughSubject<[BaseActivity], Never> = PassthroughSubject()
    
    /// Get a publisher for activities.
    /// - Returns: A publisher for a list of `BaseActivity` items.
    func getActivitiesPublisher() -> AnyPublisher<[BaseActivity], Never> {
        return publisher.eraseToAnyPublisher()
    }
    
    /// Request access to specific health data types.
    /// - Parameter completion: Callback containing the result of the request.
    func requestAccessToHealthData(completion: @escaping (Result<Bool, Error>) -> Void) {
        let readableTypes: Set<HKSampleType> = [
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKQuantityType.quantityType(forIdentifier: .appleStandTime)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
        ]
        
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(.failure(NSError(domain: "com.yourapp.healthkit", code: 1001, userInfo: ["message": "Health data is not available"])))
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: readableTypes) { success, error in
            if success {
                print("Request Authorization \(success.description)")
                completion(.success(true))
            }
        }
    }
    
    /// Fetch the statistics of a specific health data type for today.
    /// - Parameter category: The health data type category as a string.
    func getTodayStats(by category: String) {
        guard let type = HKQuantityType.quantityType(forIdentifier: typeByCategory(category: category)) else {
            print("Error: Identifier .stepCount")
            return
        }
        // This query listens changes when a user does more steps
        observerQuery = HKObserverQuery(sampleType: type, predicate: nil, updateHandler: { query, completionHandler, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            self.getMyStats(by: category)
        })
        observerQuery.map(healthStore.execute)
    }
    
    /// Fetch the statistics of a specific health data type for today.
    /// - Parameter category: The health data type category as a string.
    private func getMyStats(by category: String) {
        let type = HKQuantityType.quantityType(forIdentifier: typeByCategory(category: category))!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        self.query = HKStatisticsQuery(quantityType: type,
                                       quantitySamplePredicate: predicate,
                                       options: .cumulativeSum,
                                       completionHandler: { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    if let index = self.allMyTypes.firstIndex(where: { $0.id == category }) {
                        self.allMyTypes[index].quantity = 0
                        self.publisher.send(self.allMyTypes)
                    }
                }
                return
            }
            DispatchQueue.main.async {
                if let index = self.allMyTypes.firstIndex(where: { $0.id == category }) {
                    self.allMyTypes[index].quantity = self.value(from: sum)
                    self.publisher.send(self.allMyTypes)
                }
            }
        })
        query.map(healthStore.execute)
    }
    
    /// Convert a category string into a HealthKit data type identifier.
    /// - Parameter category: The health data type category as a string.
    /// - Returns: The corresponding HealthKit data type identifier.
    private func typeByCategory(category: String) -> HKQuantityTypeIdentifier {
        switch category {
        case "activeEnergyBurned":
            return .activeEnergyBurned
        case "appleExerciseTime":
            return .appleExerciseTime
        case "appleStandTime":
            return .appleStandTime
        case "distanceWalkingRunning":
            return .distanceWalkingRunning
        case "distanceCycling":
            return .distanceCycling
        default:
            return .stepCount
        }
    }
    
    /// Convert a `HKQuantity` object into an integer value.
    /// - Parameter stat: The `HKQuantity` object.
    /// - Returns: The integer representation of the quantity.
    private func value(from stat: HKQuantity) -> Int {
        if stat.is(compatibleWith: .kilocalorie()) {
            return Int(stat.doubleValue(for: .kilocalorie()))
        } else if stat.is(compatibleWith: .mile()) {
            return Int(stat.doubleValue(for: .meter()))
        } else if stat.is(compatibleWith: .meter()) {
            return Int(stat.doubleValue(for: .meter()))
        } else if stat.is(compatibleWith: .count()) {
            return Int(stat.doubleValue(for: .count()))
        } else if stat.is(compatibleWith: .minute()) {
            return Int(stat.doubleValue(for: .minute()))
        } else { return 0 }
    }
}
