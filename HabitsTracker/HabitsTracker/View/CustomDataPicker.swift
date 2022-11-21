//
//  CustomDataPicker.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 21/11/22.
//

import SwiftUI

struct CustomDataPicker: View {
    @Binding var currentDate: Date
    
    //Month update on arrow button clicks
    @State var currentMonth: Int = 0
    var body: some View {
        
        VStack(spacing: 35) {
            
            // Days
            let days: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            
            HStack(spacing: 20) {
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("2022")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text("November")
                        .font(.title.bold())
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Button {
                    
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
                
                
            }
            .padding(.horizontal) // invece di horizontal metterei 20 top e horizontal
            
            // Day view
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                    
                    
                }
                
            }
            
            // Dates
            // Lazy Grid
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 15) {
                
                ForEach(extractDate()) { value in
                    
                    Text("\(value.day)")
                        .font(.title3.bold())
                    
                }
            }
        }
    }
    
    func extractDate()->[DateValue] {
        let calendar = Calendar.current
        // Getting Current Month Date
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return []
        }
        
        return currentMonth.getAllDates().compactMap { date -> DateValue in
            
            // getting day
            let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
    }
}

struct CustomDataPicker_Previews: PreviewProvider {
    static var previews: some View {
        PlanningView()
    }
}

//Extending Date to get Current month Dates ...
extension Date {
    func getAllDates()->[Date] {
        let calendar = Calendar.current
        
        //getting start date of the calendar
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: self))! //TODO: evitare punto esclamativo
        
        var range = calendar.range(of: .day, in: .month, for: startDate)!
        //TODO: evitare punto esclamativo
        
        range.removeLast()
        
        //getting date...
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day == 1 ? 0 : day, to: startDate)!
            //TODO: evitare punto esclamativo
        }
    }
}
