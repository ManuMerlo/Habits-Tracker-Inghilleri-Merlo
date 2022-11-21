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
                    
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(extraDate()[1])
                        .font(.title.bold())
                        
                }
                
                Spacer(minLength: 0)
                Button {
                    // TODO: Add Activity
                    
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                }
                Button {
                    // TODO: Add alert
                    
                } label: {
                    Image(systemName: "bell")
                        .font(.title2)
                }
                .padding(.trailing, 7.0)
                
                Button {
                    withAnimation {
                        currentMonth -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Button {
                    withAnimation {
                        currentMonth += 1
                    }
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
                    CardView(value: value)
                        .background(
                            Capsule()
                                .fill(Color.pink)
                                .padding(.horizontal, 8)
                                .opacity(isSameDay(date1: value.date, date2: currentDate) ? 1 : 0)
                        )
                        .onTapGesture {
                            currentDate = value.date
                        }
                }
            }
            
            VStack(spacing: 15) {
                
                Text("Activities")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let activity = activities.first(where: { activity in
                    return isSameDay(date1: activity.activityDate, date2: currentDate)
                }) {
                    
                    ForEach(activity.activity) { activity in
                        
                        VStack(alignment: .leading, spacing: 10) {
                            
                            //For Custom Timing
                            Text(activity.time.addingTimeInterval(CGFloat.random(in: 0...5000)), style: .time)
                            
                            Text(activity.title)
                                .font(.title2.bold())
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            Color.purple
                                .opacity(0.5)
                                .cornerRadius(10)
                        )
                    }
                } else {
                    Text("No Activities Found")
                        .padding(.top, 20)
                }
            }
            .padding(.horizontal)
        }
        .onChange(of: currentMonth) { newValue in
            //Updating Month
            currentDate = getCurrentMonth()
        }
    }
    
    @ViewBuilder
    func CardView(value: DateValue)->some View{
        VStack {
            if value.day != -1 {
                if let activity = activities.first(where: { activity in
                    return isSameDay(date1: activity.activityDate, date2: value.date)
                }){
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: activity.activityDate, date2: currentDate) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    Circle()
                        .fill(isSameDay(date1: activity.activityDate, date2: currentDate) ? .white : Color.pink)
                        .frame(width: 8, height: 8)
                }
                else {
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: value.date, date2: currentDate) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
        .frame(height: 60, alignment: .top)
    }
    
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
        
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        //TODO: evitare punto esclamativo
        
        //getting date...
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
            //TODO: evitare punto esclamativo
        }
    }
}
