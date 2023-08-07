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
    
    mutating func setBirthDate(birthDate: String) {
        self.birthDate = birthDate
    }
    
    mutating func setSex(sex: Sex) {
        self.sex = sex
    }
    
    mutating func setHeight(height: Int) {
        self.height = height
    }
    
    mutating func setWeight(weight: Int) {
        self.weight = weight
    }
    
    mutating func setImage(path: String) {
        self.image = path
    }
    
    mutating func addFriend(friend: Friend){
        self.friends?.append(friend)
    }
    
    mutating func removeFriend(idFriend: String){
        self.friends?.removeAll(where: {$0.id == idFriend})
    }
    
    mutating func modifyStatusFriend(idFriend: String, newStatus: String) {
        if let index = friends?.firstIndex(where: { $0.id == idFriend }) {
                friends?[index].modifyStatus(newStatus: newStatus)
            }
    }
}

enum Sex: String, Codable, CaseIterable {
    case Female = "Female"
    case Male = "Male"
    case Unspecified = "Unspecified"
}
