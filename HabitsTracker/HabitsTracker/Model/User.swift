//
//  User.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 25/11/22.
//

import Foundation

struct User: Identifiable, Codable {
    var id = UUID().uuidString
    let username: String
    let email: String
    var age: Int
    var sex: Sex
    var weight: Float
}

enum Sex: Codable {
    case Female
    case Male
}
