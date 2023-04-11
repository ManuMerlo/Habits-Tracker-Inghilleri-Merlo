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
    var username: String?
    let email: String
    var age: Int?
    var sex: Sex?
    var weight: Float?
    var friends: [String]?
    
    //Additional
    var image: String?
    var background: String?
    var daily_score: Int?       //MARK: fix optional
    var weekly_score: Int?      //MARK: fix optional
}

enum Sex: Codable {
    case Female
    case Male
}

// MARK: samples to delete
struct UserList{
    static let usersGlobal = [
        User(username: "manu", email: "manu@gmail.com", age: 23, sex: .Female, weight: 49,image: "Avatar 4",background: "background",daily_score: 600,weekly_score: 800),
        User(username: "luigia", email: "luigia@gmail.com", age: 28, sex: .Female, weight: 44,image: "Avatar 2",background: "background",daily_score: 400,weekly_score: 900),
        User(username: "angela", email: "angela@gmail.com", age: 57, sex: .Female, weight: 41,image: "Avatar 3",background: "background",daily_score: 350,weekly_score: 700),
        User(username: "giuliana", email: "giuliana@gmail.com", age: 60, sex: .Female, weight: 55,image: "Avatar 4",background: "background",daily_score: 400,weekly_score: 500),
        User(username: "virginia", email: "virginia@gmail.com", age: 20, sex: .Female, weight: 60,image: "Avatar 1",background: "background",daily_score: 550,weekly_score: 700),
        User(username: "ricky", email: "ricky@gmail.com", age: 23, sex: .Male, weight: 68,image: "Avatar 2",background: "background",daily_score: 560,weekly_score: 980),
        User(username: "roby", email: "roby@gmail.com", age: 57, sex: .Male, weight: 65,image: "Avatar 4",background: "background",daily_score: 570,weekly_score: 650),
    ]
    
    static let usersFriends = [
        User(username: "luna", email: "manu@gmail.com", age: 23, sex: .Female, weight: 49,image: "Avatar 1",background: "background",daily_score: 670,weekly_score: 870),
        User(username: "martina", email: "luigia@gmail.com", age: 28, sex: .Female, weight: 44,image: "Avatar 2",background: "background",daily_score: 460,weekly_score: 900),
        User(username: "lucia", email: "angela@gmail.com", age: 57, sex: .Female, weight: 41,image: "Avatar 3",background: "background",daily_score: 320,weekly_score: 980),
        User(username: "marina", email: "giuliana@gmail.com", age: 60, sex: .Female, weight: 55,image: "Avatar 4",background: "background",daily_score: 470,weekly_score: 890),
        User(username: "chiara", email: "virginia@gmail.com", age: 20, sex: .Female, weight: 60,image: "Avatar 1",background: "background",daily_score: 850,weekly_score: 870),
        User(username: "massimo", email: "ricky@gmail.com", age: 23, sex: .Male, weight: 68,image: "Avatar 2",background: "background",daily_score: 550,weekly_score: 670),
        User(username: "marco", email: "roby@gmail.com", age: 57, sex: .Male, weight: 65,image: "Avatar 4",background: "background",daily_score: 570,weekly_score: 930)
    ]
}
