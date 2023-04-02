//
//  PlanningView.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 21/11/22.
//

import SwiftUI

struct PlanningView: View {
    
    @StateObject private var planningViewModel = PlanningViewModel()
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack(spacing: 35) {
                
                // Days
                let days: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                
                HStack(spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text(planningViewModel.extraDate()[0])
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Text(planningViewModel.extraDate()[1])
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
                            planningViewModel.currentMonth -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    Button {
                        withAnimation {
                            planningViewModel.currentMonth += 1
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
                    
                    ForEach(planningViewModel.extractDate()) { value in
                        CardView(value: value)
                            .background(
                                Capsule()
                                    .fill(Color.pink)
                                    .padding(.horizontal, 8)
                                    .opacity(planningViewModel.isSameDay(date1: value.date, date2: planningViewModel.currentDate) ? 1 : 0)
                            )
                            .onTapGesture {
                                planningViewModel.currentDate = value.date
                            }
                    }
                }
                
                VStack(spacing: 15) {
                    
                    Text("Activities")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let activity = activitiesPlanned.first(where: { activity in
                        return planningViewModel.isSameDay(date1: activity.activityDate, date2: planningViewModel.currentDate)
                    }) {
                        
                        ForEach(activity.activityPlanned) { activity in
                            
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
                .padding(.bottom, 15)
                
            }
            .onChange(of: planningViewModel.currentMonth) { newValue in
                //Updating Month
                planningViewModel.currentDate = planningViewModel.getCurrentMonth()
            }
            
        }
        
    }
    
    @ViewBuilder
    func CardView(value: DateValue)->some View{
        VStack {
            if value.day != -1 {
                if let activity = activitiesPlanned.first(where: { activity in
                    return planningViewModel.isSameDay(date1: activity.activityDate, date2: value.date)
                }){
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(planningViewModel.isSameDay(date1: activity.activityDate, date2: planningViewModel.currentDate) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    Circle()
                        .fill(planningViewModel.isSameDay(date1: activity.activityDate, date2: planningViewModel.currentDate) ? .white : Color.pink)
                        .frame(width: 8, height: 8)
                }
                else {
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(planningViewModel.isSameDay(date1: value.date, date2: planningViewModel.currentDate) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
        .frame(height: 60, alignment: .top)
    }
}

struct PlanningView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView(healthViewModel: HealthViewModel(), authenticationViewModel: AuthenticationViewModel())
    }
}
