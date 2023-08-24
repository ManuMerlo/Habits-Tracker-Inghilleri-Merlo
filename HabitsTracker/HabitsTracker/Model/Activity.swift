import Foundation

protocol Activity {
    var id: String { get }
    var quantity: Int? { get }
    
}

// Struct conforming to the protocol
struct BaseActivity: Activity, Equatable, Codable, Hashable {
    var id: String
    var quantity: Int?
    var timestamp: TimeInterval? 

    init(id: String, quantity: Int?, timestamp: TimeInterval?) {
        self.id = id
        self.quantity = quantity
        self.timestamp = timestamp
    }
    
    init(id: String, quantity: Int?) {
        self.id = id
        self.quantity = quantity
    }
    
    static func == (lhs: BaseActivity, rhs: BaseActivity) -> Bool {
        return lhs.id == rhs.id && lhs.quantity == rhs.quantity
        }
}

// Class extending the protocol and adding more properties
class ExtendedActivity: Activity, Hashable {
    var id: String
    var quantity: Int?
    var name: String
    var image: String
    var measure: String

    init(id: String, name: String, image: String, measure: String) {
        self.id = id
        self.name = name
        self.image = image
        self.measure = measure
    }
  
    // FIXME: we cannot use only the id
    static func == (lhs: ExtendedActivity, rhs: ExtendedActivity) -> Bool {
            return lhs.id == rhs.id
        }
    
    func hash(into hasher: inout Hasher) {
           hasher.combine(id)
       }
    
    static func allActivities() -> [ExtendedActivity] {
        return [
            ExtendedActivity(id: "activeEnergyBurned", name: "Energy Burned", image: "flame", measure: "Kcal"),
            ExtendedActivity(id: "appleExerciseTime", name: "Exercise Time", image: "figure.strengthtraining.traditional", measure:"min"),
            ExtendedActivity(id: "appleStandTime",name: "Stand Time", image: "figure.stand", measure: "min"),
            ExtendedActivity(id: "distanceWalkingRunning", name: "Distance Walking", image: "figure.walk", measure: "Km"),
            ExtendedActivity(id: "stepCount", name: "Step Count", image: "shoeprints.fill", measure: "Steps"),
            ExtendedActivity(id: "distanceCycling", name: "Distance Cycling", image: "figure.outdoor.cycle", measure: "Km")
]
    }
    
    static func getActivityByKey(key: String) -> Activity? {
        return ExtendedActivity.allActivities().first { $0.id == key }
    }
}
