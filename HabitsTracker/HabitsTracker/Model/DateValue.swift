//
//  DateValue.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 21/11/22.
//

import SwiftUI // oppure import Foundation???

//Date Value Model

struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}
