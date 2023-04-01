//
//  HealthViewModel.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 01/04/23.
//

import Foundation
import HealthKit

final class HealthViewModel: ObservableObject {
    private let healthStore: HKHealthStore = HKHealthStore()
    private var observerQuery: HKObserverQuery?
    @Published public var allMySteps: String = "10" // @Published is to update the view
    private var query: HKStatisticsQuery?
    
    func requestAccessToHealthData() {
        // HKQuantityType.quantityType(forIdentifier: .stepCount) will be deprecated maybe
        let readableTypes: Set<HKSampleType> = [HKQuantityType.quantityType(forIdentifier: .stepCount)!]
        
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: readableTypes) { success, error in
            if success {
                print("Request Authorization \(success.description)")
                self.getTodaySteps()
            }
        }
    }
    
    func getTodaySteps() {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            print("Error: Identifier .stepCount")
            return
        }
        // This query listens changes when a user does more steps
        observerQuery = HKObserverQuery(sampleType: stepCountType, predicate: nil, updateHandler: { query, completionHandler, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            self.getMySteps()
        })
        observerQuery.map(healthStore.execute)
    }
    
    private func getMySteps() {
        // Type we want obtain
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        self.query = HKStatisticsQuery(quantityType: stepsQuantityType,
                                       quantitySamplePredicate: predicate,
                                       options: .cumulativeSum,
                                       completionHandler: { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.allMySteps = String(Int(0))
                }
                return
            }
            DispatchQueue.main.async {
                self.allMySteps = String(Int(sum.doubleValue(for: HKUnit.count())))
            }
        })
        query.map(healthStore.execute)
    }
    
}
