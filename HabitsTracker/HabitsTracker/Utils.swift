import Foundation
import UIKit

extension Encodable{
    func asDictionary()->[String:Any]{
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String:Any]
            return json ?? [:]
        } catch {
            return [:]
        }
    }
}

extension Array where Element == BaseActivity {
    func asDictionaries() -> [[String: Any]] {
        return self.map { $0.asDictionary() }
    }
}

extension User {
    init?(dictionary: [String: Any]) {
        // Mandatory fields
        guard let id = dictionary["id"] as? String,
              let email = dictionary["email"] as? String else {
            return nil
        }
        
        self.id = id
        self.email = email
        
        // Optional fields
        self.username = dictionary["username"] as? String
        self.birthDate = dictionary["birthDate"] as? String
        if let sexString = dictionary["sex"] as? String, let sexValue = Sex(rawValue: sexString) {
            self.sex = sexValue
        } else {
            self.sex = nil
        }
        self.height = dictionary["height"] as? Int
        self.weight = dictionary["weight"] as? Int
        self.image = dictionary["image"] as? String
        
        if let dailyScoresList = dictionary["dailyScores"] as? [Int], dailyScoresList.count == 8 {
            self.dailyScores = dailyScoresList
        } else {
            self.dailyScores = Array(repeating: 0, count: 8)
        }
        
        self.dailyGlobal = dictionary["dailyGlobal"] as? Int
        self.dailyPrivate = dictionary["dailyPrivate"] as? Int
        self.weeklyGlobal = dictionary["weeklyGlobal"] as? Int
        self.weeklyPrivate = dictionary["weeklyPrivate"] as? Int
        
        // Handling BaseActivity records
        if let recordsList = dictionary["records"] as? [[String: Any]] {
            self.records = recordsList.compactMap { dict -> BaseActivity? in
                guard let id = dict["id"] as? String,
                      let quantity = dict["quantity"] as? Int else {
                    return nil
                }
                return BaseActivity(id: id, quantity: quantity)
            }
        } else {
            self.records = [
                BaseActivity(id:"activeEnergyBurned", quantity: 0),
                BaseActivity(id:"appleExerciseTime", quantity: 0),
                BaseActivity(id:"appleStandTime", quantity: 0),
                BaseActivity(id:"distanceWalkingRunning", quantity: 0),
                BaseActivity(id:"stepCount", quantity: 0),
                BaseActivity(id:"distanceCycling", quantity: 0)
            ]
        }
    }
}

extension UIApplication {
    // Root Controller
    func rootController() -> UIViewController {
        guard let window = connectedScenes.first as? UIWindowScene else {return .init()}
        guard let viewController = window.windows.last?.rootViewController else {return .init()}
        return viewController
    }
}


