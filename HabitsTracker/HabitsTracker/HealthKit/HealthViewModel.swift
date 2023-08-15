//
//  HealthViewModel.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 01/04/23.
//

import Foundation
import HealthKit
import SwiftUI

final class HealthViewModel: ObservableObject {
    private let healthStore: HKHealthStore = HKHealthStore()
    private var observerQuery: HKObserverQuery?
    private var query: HKStatisticsQuery?
        
    @Published public var allMyTypes: [BaseActivity] = [
        BaseActivity(id:"activeEnergyBurned", quantity: 0),
        BaseActivity(id:"appleExerciseTime", quantity: 0),
        BaseActivity(id:"appleStandTime", quantity: 0),
        BaseActivity(id:"distanceWalkingRunning", quantity: 0),
        BaseActivity(id:"stepCount", quantity: 0),
        BaseActivity(id:"distanceCycling", quantity: 0),
        
    ]
    
    
    @Published var dailyScore: Int = 0
    @Published var singleScore: [String: Int] = [:]
    
    func computeSingleScore(){
        for activity in allMyTypes {
            if let quantity = activity.quantity {
                singleScore[activity.id] = quantity / 100
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
    
    func requestAccessToHealthData() {
        let readableTypes: Set<HKSampleType> = [
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKQuantityType.quantityType(forIdentifier: .appleStandTime)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
        ]
        
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: readableTypes) { success, error in
            if success {
                print("Request Authorization \(success.description)")
                for activity in ExtendedActivity.allActivities() {
                    self.getTodayStats(by: activity.id)
                }
            }
        }
    }
    
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
    
    private func getMyStats(by category: String) {
        // Type we want obtain
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
                    }
                }
                return
            }
            DispatchQueue.main.async {
                if let index = self.allMyTypes.firstIndex(where: { $0.id == category }) {
                    self.allMyTypes[index].quantity = self.value(from: sum)
                }
            }
        })
        query.map(healthStore.execute)
        
    }
    
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
