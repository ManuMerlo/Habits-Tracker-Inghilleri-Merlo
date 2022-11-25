//
//  Goal.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 25/11/22.
//

import Foundation

struct Goal: Identifiable, Codable {
    var id = UUID().uuidString
    let name: String
    let description: String
    let score: Int
    let time: Time
}

enum Time: Codable {
    case Daily
    case Weekly
    case Monthly
}
