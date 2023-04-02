//
//  Activity.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 2/04/23.
//

import Foundation

struct Activity: Identifiable {
    var id: String
    var name: String
    var image: String
    
    static func allActivities() -> [Activity] {
        return [
            Activity(id: "activeEnergyBurned", name: "Active Energy Burned", image: "flame"),
            Activity(id: "appleExerciseTime", name: "Exercise Time", image: "figure.strengthtraining.traditional"),
            Activity(id: "appleStandTime", name: "Stand Time", image: "figure.stand"),
            Activity(id: "distanceWalkingRunning", name: "Distance Walking/Running", image: "figure.walk"),
            Activity(id: "stepCount", name: "Step Count", image: "👣"),
        ]
    }
}
