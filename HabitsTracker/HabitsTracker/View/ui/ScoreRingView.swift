//
//  ScoreRingView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 11/08/23.
//

import SwiftUI

struct ScoreRingView: View {
    
    var user: User
    var today = ( Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    
    private let gradient = AngularGradient(
        gradient: Gradient(colors: [Color(red: 0.7, green: 0.3, blue: 0.9),Color(red: 1, green: 0.8, blue: 0.9)]),
        center: .center,
        startAngle: .degrees(180),
        endAngle: .degrees(0))
    
    private let gradient2 = AngularGradient(
        gradient: Gradient(colors: [Color(red: 0, green: 0.8, blue: 0), Color(red: 1, green: 1, blue: 0.8)]),
        center: .center,
        startAngle: .degrees(180),
        endAngle: .degrees(0))
    
    var body: some View {
        ZStack{
            
            ZStack{
                Circle()
                    .stroke(Color.gray, lineWidth: 20).opacity(0.3)
                    .frame(width: 300, height: 300, alignment: .center)
                
                
                let weeklyScore = Double(user.dailyScores[7])
                let maximumScore = 200.0
                let ratioWeekly = weeklyScore / maximumScore
                
                Circle()
                    .trim( from: 0, to: CGFloat(ratioWeekly))
                    .stroke(gradient, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 300, height: 300, alignment: .center)
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0.0, y: 0.0)
                    .rotationEffect(.degrees(-90))
                
                
            }.frame(width: 400, height: 400, alignment: .center)
            
            
            Circle()
            
                .stroke(Color.gray, lineWidth: 20).opacity(0.3)
                .frame(width: 230, height: 230, alignment: .center)
            
            let dailyScore = Double(user.dailyScores[today])
            let maximumScore = 100.0
            let ratioDaily = dailyScore / maximumScore
            
            Circle()
                .trim( from: 0, to: CGFloat(ratioDaily))
                .stroke(gradient2, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .frame(width: 230, height: 230, alignment: .center)
                .rotationEffect(.degrees(-270))
                .shadow(color: .black.opacity(0.5), radius: 5, x: 0.0, y: 0.0)
                .rotationEffect(.degrees(-90))
            
            VStack(alignment: .center){
                
                
                
                Text("Daily:")
                    .font(.title2)
                    .foregroundColor(Color.black)
                
                Text(" \(user.dailyScores[today])")
                    .font(.headline)
                    .fontWeight(.thin)
                    .foregroundColor(Color.black)
                
                
                
                Spacer().frame(height: 10, alignment: .center)
                
                
                
                Text("Weekly:")
                    .font(.title2)
                    .foregroundColor(Color.black)
                
                Text("\(user.dailyScores[7])")
                    .font(.headline)
                    .fontWeight(.thin)
                    .foregroundColor(Color.black)
                
            }
            
        }
    }
}


struct ScoreRingView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreRingView(user: User(
            username: "lulu",
            email: "lulu@gmail.com",
            birthDate: "10/08/2001",
            sex: Sex.Female,
            height: 150,
            weight: 60,
            image: "",
            dailyScores: [20,50,40,60,60,90,70,80,40]))
    }
}
