//
//  Activity.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 21/11/22.
//

import SwiftUI

// Activity Model and Sample of activities
// Array of activities
struct Activity: Identifiable {
    var id = UUID().uuidString
    var title: String
    var time: Date = Date()
}

// Total Activity Meta View
struct ActivityMetaData: Identifiable {
    var id = UUID().uuidString
    var activity: [Activity]
    var activityDate: Date
}

// Sample Date for Testing
func getSampleDate(offset: Int)->Date {
    let calendar = Calendar.current
    
    let date = calendar.date(byAdding: .day, value: offset, to: Date())
    
    return date ?? Date()
}

// Sample activities
var activities: [ActivityMetaData] = [
    
    ActivityMetaData(activity: [
        Activity(title: "Walk"),
        Activity(title: "Running"),
        Activity(title: "Gym")
    ], activityDate: getSampleDate(offset: 1)),
    
    ActivityMetaData(activity: [
        Activity(title: "Basket")
    ], activityDate: getSampleDate(offset: -3)),
    
    ActivityMetaData(activity: [
        Activity(title: "Football")
    ], activityDate: getSampleDate(offset: -8)),
    
    ActivityMetaData(activity: [
        Activity(title: "Volleyball")
    ], activityDate: getSampleDate(offset: 10)),
    
    ActivityMetaData(activity: [
        Activity(title: "act0")
    ], activityDate: getSampleDate(offset: -22)),
    
    ActivityMetaData(activity: [
        Activity(title: "act1")
    ], activityDate: getSampleDate(offset: 15)),
    
    ActivityMetaData(activity: [
        Activity(title: "act2")
    ], activityDate: getSampleDate(offset: -20)),
]
