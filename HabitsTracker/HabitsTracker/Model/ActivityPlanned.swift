//
//  ActivityPlanned.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 21/11/22.
//

import SwiftUI

// Activity Model and Sample of activities
// Array of activities
struct ActivityPlanned: Identifiable {
    var id = UUID().uuidString
    var title: String
    var time: Date = Date()
}

// Total Activity Meta View
struct ActivityPlannedMetaData: Identifiable {
    var id = UUID().uuidString
    var activityPlanned: [ActivityPlanned]
    var activityDate: Date
}

// Sample Date for Testing
func getSampleDate(offset: Int)->Date {
    let calendar = Calendar.current
    
    let date = calendar.date(byAdding: .day, value: offset, to: Date())
    
    return date ?? Date()
}

// Sample activities
var activitiesPlanned: [ActivityPlannedMetaData] = [
    
    ActivityPlannedMetaData(activityPlanned: [
        ActivityPlanned(title: "Walk"),
        ActivityPlanned(title: "Running"),
        ActivityPlanned(title: "Gym")
    ], activityDate: getSampleDate(offset: 1)),
    
    ActivityPlannedMetaData(activityPlanned: [
        ActivityPlanned(title: "Basket")
    ], activityDate: getSampleDate(offset: -3)),
    
    ActivityPlannedMetaData(activityPlanned: [
        ActivityPlanned(title: "Football")
    ], activityDate: getSampleDate(offset: -8)),
    
    ActivityPlannedMetaData(activityPlanned: [
        ActivityPlanned(title: "Volleyball")
    ], activityDate: getSampleDate(offset: 10)),
    
    ActivityPlannedMetaData(activityPlanned: [
        ActivityPlanned(title: "act0")
    ], activityDate: getSampleDate(offset: -22)),
    
    ActivityPlannedMetaData(activityPlanned: [
        ActivityPlanned(title: "act1")
    ], activityDate: getSampleDate(offset: 15)),
    
    ActivityPlannedMetaData(activityPlanned: [
        ActivityPlanned(title: "act2")
    ], activityDate: getSampleDate(offset: -20)),
]
