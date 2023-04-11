//
//  User.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 25/11/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User : Identifiable, Codable {

    @DocumentID var id: String?
    //var username: String?
    let email: String
    var age: Int?
    var sex: Sex?
    var weight: Float?
    var friends: [String]?
}

enum Sex: Codable {
    case Female
    case Male
}
