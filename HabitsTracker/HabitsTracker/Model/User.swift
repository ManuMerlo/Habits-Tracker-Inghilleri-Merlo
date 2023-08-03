struct User: Identifiable, Codable, Hashable {

    let id: String
    var username: String?
    let email: String
    var age: Int?
    var sex: Sex?
    var weight: Float?
    var friends: [String]?
    
    //Additional
    var image: String?
    var daily_score: Int?       //MARK: fix optional
    var weekly_score: Int?      //MARK: fix optional
    
    mutating func setUsername(name: String) {
        self.username = name
    }
    
    mutating func setAge(age: Int) {
        self.age = age
    }
    
    mutating func setSex(sex: Sex) {
        self.sex = sex
    }
    
    mutating func setWeight(weight: Float) {
        self.weight = weight
    }
    
}

enum Sex: Codable {
    case Female
    case Male
}

// MARK: samples to delete
struct UserList{
    static let usersGlobal = [
        User(id:"1",username: "manu", email: "manu@gmail.com", age: 23, sex: .Female, weight: 49,image: "Avatar 4",daily_score: 600,weekly_score: 800),
        User(id:"2",username: "luigia", email: "luigia@gmail.com", age: 28, sex: .Female, weight: 44,image: "Avatar 2",daily_score: 400,weekly_score: 900),
        User(id:"3",username: "angela", email: "angela@gmail.com", age: 57, sex: .Female, weight: 41,image: "Avatar 3",daily_score: 350,weekly_score: 700),
        User(id:"4",username: "giuliana", email: "giuliana@gmail.com", age: 60, sex: .Female, weight: 55,image: "Avatar 4",daily_score: 400,weekly_score: 500),
        User(id:"5",username: "virginia", email: "virginia@gmail.com", age: 20, sex: .Female, weight: 60,image: "Avatar 1",daily_score: 550,weekly_score: 700),
        User(id:"6",username: "ricky", email: "ricky@gmail.com", age: 23, sex: .Male, weight: 68,image: "Avatar 2",daily_score: 560,weekly_score: 980),
        User(id:"7",username: "roby", email: "roby@gmail.com", age: 57, sex: .Male, weight: 65,image: "Avatar 4",daily_score: 570,weekly_score: 650),
    ]
    
    static let usersFriends = [
        User(id:"1",username: "luna", email: "manu@gmail.com", age: 23, sex: .Female, weight: 49,image: "Avatar 1",daily_score: 670,weekly_score: 870),
        User(id:"2",username: "martina", email: "luigia@gmail.com", age: 28, sex: .Female, weight: 44,image: "Avatar 2",daily_score: 460,weekly_score: 900),
        User(id:"3",username: "lucia", email: "angela@gmail.com", age: 57, sex: .Female, weight: 41,image: "Avatar 3",daily_score: 320,weekly_score: 980),
        User(id:"4",username: "marina", email: "giuliana@gmail.com", age: 60, sex: .Female, weight: 55,image: "Avatar 4",daily_score: 470,weekly_score: 890),
        User(id:"5",username: "chiara", email: "virginia@gmail.com", age: 20, sex: .Female, weight: 60,image: "Avatar 1",daily_score: 850,weekly_score: 870),
        User(id:"6",username: "massimo", email: "ricky@gmail.com", age: 23, sex: .Male, weight: 68,image: "Avatar 2",daily_score: 550,weekly_score: 670),
        User(id:"7",username: "marco", email: "roby@gmail.com", age: 57, sex: .Male, weight: 65,image: "Avatar 4",daily_score: 570,weekly_score: 930)
    ]
}
