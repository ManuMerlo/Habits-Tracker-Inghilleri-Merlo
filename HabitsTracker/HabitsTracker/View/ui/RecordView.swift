//
//  RecordView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 15/08/23.
//

import SwiftUI

struct RecordView: View {
    
    var user : User
    var elementSize : CGFloat
    
    var body: some View {
        VStack{
            Text("Records")
                .font(.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            
            let columns = [
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 0),
            ]
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(ExtendedActivity.allActivities().enumerated()), id: \.element.id) { index, activity in
                    if let record = user.records.first(where: { $0.id == activity.id }) {
                        RecordDetailView(
                            activityType: activity.name,
                            quantity: record.quantity ?? 0,
                            image: activity.image,
                            measure: activity.measure,
                            color: index,
                            up: record.timestamp == Calendar.current.startOfDay(for: Date()).timeIntervalSince1970 ? true : false,
                            width: elementSize
                        )
                    }
                }
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(
            user: User(
                username: "lulu",
                email: "lulu@gmail.com",
                birthDate: "10/08/2001",
                sex: Sex.Female,
                height: 150,
                weight: 60,
                image: "",
                dailyScores: [20,50,40,60,60,90,70,200,40]),
            elementSize : 200)
    }
}
