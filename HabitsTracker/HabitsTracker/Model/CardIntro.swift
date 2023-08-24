import Foundation
import SwiftUI

struct Card: Identifiable {
    var id  = UUID()
    var title : String
    var description : String
}

var data: [Card] = [

Card( title: "Track your habits 📋", description: "Be always up to date with what you did during the day."),

Card( title: "Compete 🏆", description: "Share your results and don't let anyone overtake you in the rankings!"),

Card( title: "Plan your Activities ⛰️", description: "Plan your activities and let your community members participate with you"),

]
