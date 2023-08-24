import SwiftUI // oppure import Foundation???


struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}
