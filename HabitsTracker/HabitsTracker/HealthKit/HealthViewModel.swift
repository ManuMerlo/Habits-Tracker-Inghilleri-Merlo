import Foundation
import HealthKit
import SwiftUI
import Combine

@MainActor
final class HealthViewModel: ObservableObject {
    
    @Published var allMyTypes: [BaseActivity] = [
        BaseActivity(id: "activeEnergyBurned", quantity: 0),
        BaseActivity(id: "appleExerciseTime", quantity: 0),
        BaseActivity(id: "appleStandTime", quantity: 0),
        BaseActivity(id: "distanceWalkingRunning", quantity: 0),
        BaseActivity(id: "stepCount", quantity: 0),
        BaseActivity(id: "distanceCycling", quantity: 0),
    ]
    @Published var dailyScore: Int = 0
    @Published var singleScore: [String: Int] = [:]
    
    private let pointValues: [String : Double] = [
        "activeEnergyBurned" : 0.2,   // 0.2 points per kilocalorie
        "appleExerciseTime" : 1,      // 1 point per minute
        "appleStandTime" : 0.03,      // 0.03 points per minute
        "distanceWalkingRunning" : 5, // 5 points per kilometer
        "stepCount" : 0.005,          // 0.005 points per step
        "distanceCycling" : 3         // 3 points per kilometer
    ]
    
    private let healthRepository: HealthRepository
    private var cancellables: Set<AnyCancellable> = []
 
    //Production
    init(healthRepository: HealthRepository = HealthRepository()) {
        self.healthRepository = healthRepository
        subscribeToUpdates()
    }
    
    //Testing
    init(withRepository healthRepository: HealthRepository) {
        self.healthRepository = healthRepository
        subscribeToUpdates()
    }

    private func subscribeToUpdates() {
           healthRepository.getActivitiesPublisher()
               .sink { [weak self] activities in
                   self?.allMyTypes = activities
               }
               .store(in: &cancellables)
    }
    
    func computeSingleScore() {
        for activity in allMyTypes {
            if let quantity = activity.quantity {
                singleScore[activity.id] = Int(round(Double(quantity) * (pointValues[activity.id] ?? 0)))
            } else {
                singleScore[activity.id] = 0
            }
        }
        
    }
    
    func updateRecords(records: inout [BaseActivity]) -> Bool {
        var flag = false
        for activity in allMyTypes {
            if let quantity = activity.quantity {
                if let recordIndex = records.firstIndex(where: { $0.id == activity.id }), records[recordIndex].quantity ?? 0 < quantity {
                    records[recordIndex].quantity = quantity
                    records[recordIndex].timestamp = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
                    flag = true
                }
            }
        }
        return flag
    }
    
    func computeTotalScore() {
        self.dailyScore = singleScore.values.reduce(0, +)
    }
    
    func requestAccessToHealthData(){
        healthRepository.requestAccessToHealthData { result in
            switch result {
            case .success(_):
                print("Successfully obtained authorization")
                for activity in ExtendedActivity.allActivities() {
                    self.healthRepository.getTodayStats(by: activity.id)
                }
            case .failure(let error):
                print("Failed to obtain authorization with error: \(error)")
            }
        }
    }
    
}
