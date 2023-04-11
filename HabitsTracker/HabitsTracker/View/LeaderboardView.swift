//
//  LeaderboardView.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 26/03/23.
//

//TODO : da implementare
/*switch selectedTimeFrame {
 case .weekly:
 users = viewModel.weeklyUsers
 case .daily:
 users = viewModel.dailyUsers
 }*/

import SwiftUI


struct LeaderboardView: View {
    @State private var global : Bool = true
    @State private var selectedTimeFrame : TimeFrame = .daily
    @State var users : [User] = UserList.usersGlobal
    
    var body: some View {
        
        NavigationStack {
            GeometryReader { geometry in
                VStack{
                    Picker("Choose a time frame", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases,id: \.self){
                            Text($0.rawValue)
                        }
                    }.onChange(of: selectedTimeFrame , perform: { newValue in
                        sortUsers(timeFrame: newValue)
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom,30)
                    
                    
                    ZStack{
                        NavigationLink(value: users[1] ){
                            RankingPodiumView(user: users[1],
                                              selectedTimeFrame: selectedTimeFrame,
                                              position: "2",
                                              width: (geometry.size.width - 70) * 0.4,
                                              color: CommodityColor.silver.linearGradient,
                                              squareSide: geometry.size.width - 290)
                            .offset(x:-geometry.size.width/4,y: 10)
                        }
                        
                        
                        NavigationLink(value: users[2]){
                            RankingPodiumView(user: users[2],
                                              selectedTimeFrame: selectedTimeFrame,
                                              position: "3",
                                              width: (geometry.size.width - 70) * 0.4,
                                              color: CommodityColor.bronze.linearGradient,
                                              squareSide:geometry.size.width - 290)
                            .offset(x:geometry.size.width/4,y: 10)
                        }
                        
                        NavigationLink(value: users[0]){
                            RankingPodiumView(user: users[0],
                                              selectedTimeFrame: selectedTimeFrame,
                                              position: "1",
                                              width: (geometry.size.width - 70) * 0.5,
                                              color: CommodityColor.gold.linearGradient,
                                              squareSide:geometry.size.width - 260)
                            .offset(y:-geometry.size.height/12)
                        }
                    }
                    .padding(.top,30)
                                    
                    ScrollView {
                        LazyVStack {
                            ForEach(4..<users.count) { item in
                                NavigationLink(value: users[item - 1]){
                                    RankingItemView(user : users[item-1],
                                                    selectedTimeFrame: selectedTimeFrame,
                                                    position: item )
                                }
                            }
                        }
                    }.padding(.top,10)
                    
                } .toolbar {
                    Button {
                        global.toggle()
                    } label: {
                        if global {
                            Text("Global")
                            Image(systemName: "globe")
                        } else {
                            Text("Private")
                            Image(systemName: "person")
                        }
                    }.onChange(of: global) { newValue in
                        setUsers(global: newValue)
                    }
                }.padding(20)
                    .navigationTitle("Leaderboard")
                    .navigationDestination(for: User.self) { user in
                        DetailUserView(user: user)
                    }
            }
        }.onAppear(){
            sortUsers(timeFrame: selectedTimeFrame)
        }
    }
    
    func sortUsers(timeFrame: TimeFrame){
        if timeFrame == .daily{
            users.sort { user1, user2 in
                user1.daily_score ?? 0 > user2.daily_score ?? 0  //MARK: fix score optional
            }
        } else {
            users.sort { user1, user2 in
                user1.weekly_score ?? 0 > user2.weekly_score ?? 0   //MARK: fix score optional
            }
        }
    }
    
    func setUsers( global: Bool){
        if global == true {
            users = UserList.usersGlobal
        }else {
            users = UserList.usersFriends
        }
        sortUsers(timeFrame: selectedTimeFrame)
    }
}

enum TimeFrame : String, CaseIterable {
    case weekly = "Weekly"
    case daily = "Daily"
}

struct DetailUserView: View{
    var user: User
    var body: some View {
        VStack{
            if let background = user.background {
                Image(background)
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(height: 200, alignment: .center)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius:10))
                    .padding([.leading,.trailing])
            }
            VStack{
                if let image = user.image{
                    Image(image)
                        .resizable()
                        .clipped()
                        .clipShape(Circle())
                        .aspectRatio(contentMode: ContentMode.fill)
                        .frame(width: 120,height: 120)
                }
                if let username = user.username{
                    Text(username)
                        .font(.title3)
                        .bold()
                }
            }.offset(y:-60)
            Spacer()
        }
    }
    
}

struct RankingPodiumView: View {
    let user : User
    var selectedTimeFrame : TimeFrame
    let position: String
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

            
            ImageOnCircle(icon: user.image ?? "user", radius: width/2.2, circleColor: color, imageColor: .white,squareSide: squareSide)
            
            Text(user.username ?? user.email)
                    .foregroundColor(.black)
                    .font(.title3)
                    .bold()
            
            
            Text( selectedTimeFrame == .daily ? "\(user.daily_score ?? 0)" : "\(user.weekly_score ?? 0)")
                .foregroundColor(.black)
                .font(.callout)
                .bold()
        }
        
    }
    
}

struct RankingItemView: View {
    var user : User
    var selectedTimeFrame : TimeFrame
    var position : Int
    
    var body: some View {
        HStack(spacing: 20) {
            VStack {
                Text("\(position)")
                    .font(.callout)
                    .fontWeight(.bold)
                Text("⏷")
            }.padding(.horizontal,10)
            
            Image(user.image ?? "user")
                .resizable()
                .frame(width: 50, height: 50)
                .mask(Circle())
            
            Text(user.username ?? user.email)
                .font(.body)
                .fontWeight(.bold)
                .frame(width: 100)
            
            Divider()
            Text(selectedTimeFrame == .daily ? "\(user.daily_score ?? 0)" : "\(user.weekly_score ?? 0)")
                .fontWeight(.bold)
            
        }
        .padding(.vertical,10)
        .frame(maxWidth: .infinity, maxHeight: 80)
        .background(position % 2 == 0 ? LinearGradient(colors: [Color.green, Color.green.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [Color.purple, Color.purple.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .foregroundColor(.white)
        .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
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

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}



