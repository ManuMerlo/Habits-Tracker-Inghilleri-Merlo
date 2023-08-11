//
//  Activity.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 2/04/23.
//

import Foundation

protocol Activity {
    var id: String { get }
    var quantity: Int? { get }
    
}

// Struct conforming to the protocol
struct BaseActivity: Activity, Equatable {
    var id: String
    var quantity: Int?
    
    init(id: String, quantity: Int?) {
        self.id = id
        self.quantity = quantity
    }
    
    static func == (lhs: BaseActivity, rhs: BaseActivity) -> Bool {
            return lhs.id == rhs.id
        }
}

// Class extending the protocol and adding more properties
class ExtendedActivity: Activity, Hashable {
    var id: String
    var quantity: Int?
    var name: String
    var image: String
    var measure: String

    init(id: String, name: String, image: String, measure: String) {
        self.id = id
        self.name = name
        self.image = image
        self.measure = measure
    }
  
    static func == (lhs: ExtendedActivity, rhs: ExtendedActivity) -> Bool {
            return lhs.id == rhs.id
        }
    
    func hash(into hasher: inout Hasher) {
           hasher.combine(id)
       }
    
    static func allActivities() -> [ExtendedActivity] {
        return [
            ExtendedActivity(id: "activeEnergyBurned", name: "Active Energy Burned", image: "flame", measure: "Kcal"),
            ExtendedActivity(id: "appleExerciseTime", name: "Exercise Time", image: "figure.strengthtraining.traditional", measure:"min"),
            ExtendedActivity(id: "appleStandTime",name: "Stand Time", image: "figure.stand", measure: "min"),
            ExtendedActivity(id: "distanceWalkingRunning", name: "Distance Walking/Running", image: "figure.walk", measure: "Km"),
            ExtendedActivity(id: "stepCount", name: "Step Count", image: "shoeprints.fill", measure: "Steps")
            ]
    }
    
    static func getActivityByKey(key: String) -> Activity? {
        return ExtendedActivity.allActivities().first { $0.id == key }
    }
}
