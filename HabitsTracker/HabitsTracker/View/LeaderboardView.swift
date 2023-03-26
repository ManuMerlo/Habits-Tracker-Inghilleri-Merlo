//
//  LeaderboardView.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 26/03/23.
//

import SwiftUI

struct LeaderboardView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Leaderboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                HStack (spacing: 7) {
                    RankingCard(position: "2nd",
                                image_path: "Avatar 2",
                                username: "Player 2",
                                score: 400,
                                width: (geometry.size.width - 60) * 0.328,
                                height: geometry.size.height/4,
                                color: CommodityColor.silver.linearGradient)
                    RankingCard(position: "1st",
                                image_path: "Avatar 1",
                                username: "Player 1",
                                score: 500,
                                width: (geometry.size.width - 60) * 0.364,
                                height: geometry.size.height/3.5,
                                color: CommodityColor.gold.linearGradient)
                    RankingCard(position: "3rd",
                                image_path: "Avatar 3",
                                username: "Player 3",
                                score: 300,
                                width: (geometry.size.width - 60) * 0.308,
                                height: geometry.size.height/4.5,
                                color: CommodityColor.bronze.linearGradient)
                }
                List(0..<20) { item in
                    HStack {
                        Text("\(item + 4)").frame(width: geometry.size.width / 15)
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                        Image("Avatar 1")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .mask(Circle())
                            .padding(.trailing, 8.0)
                        
                        Text("username").padding(.trailing)
                        Spacer()
                        Text("300 pt")
                            .fontWeight(.bold)
                    }
                }.scrollContentBackground(.hidden)
            }
            
        }
    }
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
    let height: CGFloat
    let color: LinearGradient
    
    var body: some View {
        VStack() {
            Spacer()
            Text(position)
            Spacer()
            Image(image_path)
                .resizable()
                .frame(width: width * 0.65, height:  width * 0.65)
                .mask(Circle())
            Spacer()
            Text(username)
            Spacer()
            Text("\(score) pt")
            Spacer()
        }.foregroundColor(.black)
            .padding(5)
            .frame(width: width, height: height)
            .background(color)
            .mask(RoundedRectangle(cornerRadius: 30,style: .continuous))
            .shadow(color: Color.gray.opacity(0.3), radius: 8, x: 0, y: 12)
            .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 1)
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
