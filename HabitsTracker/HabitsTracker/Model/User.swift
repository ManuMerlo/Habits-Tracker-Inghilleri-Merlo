//
//  User.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 25/11/22.
//

import Foundation

struct User: Identifiable, Codable {

    let id: String // documentID == uid
    let username: String
    let emailAddress: String
    var age: Int?
    var sex: Sex?
    var weight: Float?
    var friends: [String]?
}

enum Sex: Codable {
    case Female
    case Male
}
