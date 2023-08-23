//
//  ScoreRingView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 11/08/23.
//

import SwiftUI

struct ScoreRingView: View {
    
    var dailyScore : Int
    var weeklyScore: Int
    var ringSize : CGFloat
    var today = ( Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    
    private let gradient = AngularGradient(
        gradient: Gradient(colors: [Color("skyBlue"),Color("magenta"),Color("phlox")]),
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(352))
    
    private let gradient2 = AngularGradient(
        gradient: Gradient(colors: [Color(red: 1, green: 1, blue: 0.8),Color(red: 0, green: 0.8, blue: 0.2),Color(red: 0, green: 0.4, blue: 0.28)]),
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(352))
    
    var body: some View {
        
        let ringSize = max(290,ringSize)
        
        ZStack{
            
                Circle()
                    .stroke(Color("platinum"), lineWidth: 20).opacity(0.3)
                    .frame(width: ringSize, alignment: .center)
                
                
                
                let maximumScoreW = 200.0
                let ratioWeekly = Double(weeklyScore) / maximumScoreW
                
                Circle()
                    .trim( from: 0, to: CGFloat(ratioWeekly))
                    .stroke(gradient, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: ringSize,alignment: .center)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0.0, y: 0.0)
            
            
            Circle()
                .stroke(Color("platinum"), lineWidth: 20).opacity(0.3)
                .frame(width: ringSize-60, alignment: .center)
       
            let maximumScoreD = 100.0
            let ratioDaily = Double(dailyScore) / maximumScoreD
            
            Circle()
                .trim( from: 0, to: CGFloat(ratioDaily))
                .stroke(gradient2, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .frame(width: ringSize - 60, alignment: .center)
                .rotationEffect(.degrees(-90))
                .shadow(color: .black.opacity(0.5), radius: 5, x: 0.0, y: 0.0)
            
            VStack(alignment: .center){
                
                Text("Daily:")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                
                Text("\(dailyScore)")
                    .font(.title3)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                
                        
                Spacer().frame(height: 10, alignment: .center)
                
            
                Text("Weekly:")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                
                Text("\(weeklyScore)")
                    .font(.title3)
                    .foregroundColor(Color("magenta"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                
            }
            
        }
    }
}


struct ScoreRingView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreRingView(dailyScore:100, weeklyScore: 100, ringSize: 500)
    }
}
