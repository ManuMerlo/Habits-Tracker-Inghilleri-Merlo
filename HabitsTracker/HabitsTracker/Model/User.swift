import FirebaseFirestore

struct User: Identifiable, Codable, Hashable {

    var id: String?
    var username: String?
    let email: String
    var birthDate: String?
    var sex: Sex?
    var height: Int?
    var weight: Int?
    var friends: [Friend]?
    
    //Additional
    var image: String?
    var daily_score: Int?     //MARK: fix optional
    var weekly_score: Int?     //MARK: fix optional
    
    mutating func setUsername(name: String) {
        self.username = name
    }
    
}

enum Sex: String, Codable, CaseIterable {
    case Female = "Female"
    case Male = "Male"
    case Unspecified = "Unspecified"
}
