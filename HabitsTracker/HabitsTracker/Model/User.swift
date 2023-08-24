import FirebaseAuth // FIXME: needed?

struct User: Codable, Hashable {

    let id: String
    let email: String
    var username: String?
    var birthDate: String?
    var sex: Sex?
    var height: Int?
    var weight: Int?
    
    var image: String?
    var dailyScores: [Int] = Array(repeating: 0, count: 8)
    //[0 - Monday / 1 - Tuesday .. 7 = weeklyScore]
    
    //ranking
    var dailyGlobal : Int?
    var dailyPrivate : Int?
    var weeklyGlobal : Int?
    var weeklyPrivate : Int?
    
    var records: [BaseActivity] = [
        BaseActivity(id:"activeEnergyBurned", quantity: 0),
        BaseActivity(id:"appleExerciseTime", quantity: 0),
        BaseActivity(id:"appleStandTime", quantity: 0),
        BaseActivity(id:"distanceWalkingRunning", quantity: 0),
        BaseActivity(id:"stepCount", quantity: 0),
        BaseActivity(id:"distanceCycling", quantity: 0)
    ]
    
    mutating func setUsername(name: String) {
        self.username = name
    }
    
}

enum Sex: String, Codable, CaseIterable {
    case Female = "Female"
    case Male = "Male"
    case Unspecified = "Unspecified"
}
