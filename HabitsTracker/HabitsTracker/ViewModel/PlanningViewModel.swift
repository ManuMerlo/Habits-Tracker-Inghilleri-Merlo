//
//  PlanningViewModel.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 22/11/22.
//

import SwiftUI

final class PlanningViewModel: ObservableObject {
    @Published var currentDate: Date = Date()
    //Month update on arrow button clicks
    @Published var currentMonth: Int = 0
    
    // Checking dates
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    // Extrating year and Month for display
    func extraDate()->[String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        
        let date = formatter.string(from: currentDate)
        
        return date.components(separatedBy: " ")
    }
    
    func getCurrentMonth()->Date{
        let calendar = Calendar.current
        // Getting Current Month Date
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return Date()
        }
        
        return currentMonth
    }
    
    func extractDate()->[DateValue] {
        let calendar = Calendar.current
        // Getting Current Month Date
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            
            // getting day
            let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
        
        //adding offset days to exact week day
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        return days
    }
    
}

//Extending Date to get Current month Dates ...
extension Date {
    func getAllDates()->[Date] {
        let calendar = Calendar.current
        
        //getting start date of the calendar
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: self))! //TODO: evitare punto esclamativo
        
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        //TODO: evitare punto esclamativo
        
        //getting date...
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
            //TODO: evitare punto esclamativo
        }
    }
}
