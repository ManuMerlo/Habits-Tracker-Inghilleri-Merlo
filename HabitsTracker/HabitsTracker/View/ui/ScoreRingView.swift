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
    
    var body: some View {
        
        let ringSize = max(290,ringSize)
        
        ZStack{
            
            let maximumScoreW = 7000.0
            let ratioWeekly = Double(weeklyScore) / maximumScoreW
            
            RingView(progress: ratioWeekly, colors: [Color("skyBlue"),Color("magenta"),Color("phlox")], width: ringSize)
            
            let maximumScoreD = 1000.0
            let ratioDaily = Double(dailyScore) / maximumScoreD
            
            RingView(progress: ratioDaily, colors: [Color(red: 1, green: 1, blue: 0.8),Color(red: 0, green: 0.8, blue: 0.2),Color(red: 0, green: 0.4, blue: 0.28)], width: ringSize-60)
            
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

struct RingView: View {
    var progress: Double
    var colors: [Color]
    var width: CGFloat
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("platinum"), lineWidth: 20).opacity(0.3)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            Gradient.Stop(color: colors[0], location: 0),
                            Gradient.Stop(color: colors[1], location: 0.7),
                            Gradient.Stop(color: colors[2].opacity(0.8), location: 1),
                        ]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: .black.opacity(0.5), radius: 5, x: 0.0, y: 0.0)
            
            if progress > 1 {
                Circle()
                    .trim(from: 0, to: progress - 1)
                    .stroke( colors[2],
                             style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    ).rotationEffect(.degrees(-90))
            }
            Circle()
                .frame(width: 20, height: 20)
                .foregroundColor(progress > 1 ? colors[2] : colors[0])
                .offset(y:-width/2)
            if progress < 1 {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(progress > 1 ? colors[2] : Color.clear)
                    .rotationEffect(Angle.degrees(360 * Double(progress)))
                    .shadow(color: progress > 0.96 ? Color.black.opacity(0.1): Color.clear, radius: 3, x: 4, y: 0)
                    .offset(y:-width/2)
            }
        }.frame(width: width, height: width, alignment: .center)
    }
}



struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                .edgesIgnoringSafeArea(.all)
            ScoreRingView(dailyScore: 700, weeklyScore: 7200, ringSize: 300)
        }
    }
}
