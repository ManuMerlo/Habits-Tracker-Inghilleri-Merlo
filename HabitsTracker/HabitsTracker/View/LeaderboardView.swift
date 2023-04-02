//
//  LeaderboardView.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 26/03/23.
//

import SwiftUI


struct LeaderboardView: View {
    
    @State private var selectedTimeFrame : TimeFrame = .daily
    var body: some View {
        
        GeometryReader { geometry in

            VStack {
                
                Text("Leaderboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                
                Picker("Choose a time frame",selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases,id: \.self){
                        Text($0.rawValue)
                    }
                }.pickerStyle(SegmentedPickerStyle())
                .padding(.bottom,30)
                .padding(.horizontal,20)
               
                //TODO : da implementare
                /*switch selectedTimeFrame {
                case .weekly:
                    users = viewModel.weeklyUsers
                case .daily:
                    users = viewModel.dailyUsers
                }*/
                
                HStack{
                    RankingCard(position: "2",
                                image_path: "Avatar 2",
                                username: "Player 2",
                                score: 400,
                                width: (geometry.size.width - 70) * 0.4,
                                color: CommodityColor.silver.linearGradient,
                                squareSide: geometry.size.width - 290)
                    .position(x:geometry.size.width/4,
                              y:geometry.size.height/4.8)
                    
                    RankingCard(position: "3",
                                image_path: "Avatar 3",
                                username: "Player 3",
                                score: 300,
                                width: (geometry.size.width - 70) * 0.4,
                                color: CommodityColor.bronze.linearGradient,
                                squareSide:geometry.size.width - 290)
                    .position(x:geometry.size.width/2.4,
                              y:geometry.size.height/4.8)
                    
                    RankingCard(position: "1",
                                image_path: "Avatar 4",
                                username: "Player 1",
                                score: 500,
                                width: (geometry.size.width - 70) * 0.5,
                                color: CommodityColor.gold.linearGradient,
                                squareSide:geometry.size.width - 260)
                    .position(x:-geometry.size.width/5.6,
                              y:geometry.size.height/8)
                    
                }
               
                ScrollView {
                    LazyVStack {
                        ForEach(0..<20) { item in
                            HStack(spacing: 20) {
                                
                                VStack {
                                    Text("\(item + 4)")
                                        .font(.callout)
                                        .fontWeight(.bold)
                                        .frame(width: geometry.size.width / 15)
                                    Text("⏷")
                                }.padding(.horizontal,10)
                                
                                Image("Avatar 1")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .mask(Circle())
                                Text("username")
                                    .font(.body)
                                    .fontWeight(.bold)
                                Divider()
                                Text("300 ")
                                    .fontWeight(.bold)
                            
                            }
                            .padding(.vertical,10)
                            .frame(maxWidth: .infinity, maxHeight: 80)
                            .background(item % 2 == 0 ? Color.green : .purple)
                            .foregroundColor(.white)
                            .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }.padding(.horizontal,20)
                    }
                }
            
            }
        }
        
    }
}

enum TimeFrame : String, CaseIterable {
    case weekly = "Weekly"
    case daily = "Daily"
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}

struct RankingCard: View {
    let position: String
    let image_path: String
    let username: String
    let score: Int
    let width: CGFloat
    let color: LinearGradient
    let squareSide: CGFloat
    
    var body: some View {
        
        VStack {
           
            if position == "1"{
                Image("crown")
                    .resizable()
                    .frame(width: 50,height: 50)
                    .scaledToFit()
            } else {
                Text(position)
                    .foregroundColor(.black)
                    .font(.title3)
                .bold()
            }
                
            ImageOnCircle(icon: image_path, radius: width/2.2, circleColor: color, imageColor: .white,squareSide: squareSide)
            Text(username)
                .foregroundColor(.black)
                .font(.title3)
                .bold()
            Text("\(score)")
                .foregroundColor(.black)
                .font(.callout)
                .bold()
        }
       
    }
    
}

struct ImageOnCircle: View {
    
    let icon: String
    let radius: CGFloat
    let circleColor: LinearGradient
    let imageColor: Color
    var squareSide: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(circleColor)
                .frame(width: radius * 2, height: radius * 2)

            Image(icon)
               .resizable()
               .mask(Circle())
               .shadow(color: Color.gray.opacity(0.3), radius: 8, x: 0, y: 12)
               .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 1)
               .aspectRatio(1.0, contentMode: .fit)
               .frame(width: squareSide, height: squareSide)
        }
    }
}

enum CommodityColor {
    case gold
    case silver
    case bronze
    var colors: [Color] {
        switch self {
        case .gold: return [ Color(red: 219/255, green: 180/255, blue: 0),
                             Color(red: 239/255, green: 175/255, blue: 0),
                             Color(red: 245/255, green: 209/255, blue: 0),
                             Color(red: 245/255, green: 209/255, blue: 0),
                             Color(red: 209/255, green: 174/255, blue: 21/255),
                             Color(red: 219/255, green: 180/255, blue: 0),
        ]
            
        case .silver: return [ Color(red: 112/255, green: 112/255, blue: 111/255),
                               Color(red: 125/255, green: 125/255, blue: 122/255),
                               Color(red: 179/255, green: 182/255, blue: 181/255),
                               Color(red: 142/255, green: 142/255, blue: 141/255),
                               Color(red: 179/255, green: 182/255, blue: 181/255),
                               Color(red: 161/255, green: 162/255, blue: 163/255),
        ]
            
        case .bronze: return [ Color(red: 128/255, green: 74/255, blue: 0),
                               Color(red: 157/255, green: 122/255, blue: 60/255),
                               Color(red: 176/255, green: 141/255, blue: 87/255),
                               Color(red: 137/255, green: 94/255, blue: 26/255),
                               Color(red: 128/255, green: 74/255, blue: 0),
                               Color(red: 176/255, green: 141/255, blue: 87/255),
        ]}
    }
    
    var linearGradient: LinearGradient
    {
        return LinearGradient(
            gradient: Gradient(colors: self.colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
