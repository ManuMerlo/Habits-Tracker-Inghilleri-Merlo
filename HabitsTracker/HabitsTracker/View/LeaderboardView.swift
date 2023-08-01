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
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    @State var users: [User] = UserList.usersGlobal
    
    var body: some View {
        
        
        NavigationStack {
            
                VStack{
                    Picker("Choose a time frame", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases,id: \.self){
                            Text($0.rawValue)
                        }
                    }.onChange(of: selectedTimeFrame , perform: { newValue in
                        sortUsers(timeFrame: newValue)
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom,8)
            
                    ScrollView {
                        LazyVStack {
                            ForEach(1..<users.count) { item in
                                NavigationLink(value: users[item - 1]){
                                    RankingItemView(user : users[item-1],
                                                    selectedTimeFrame: selectedTimeFrame,
                                                    position: item ).padding(.bottom, 95)
                                }
                            }
                        }
                    }.padding(.top,10)
                    
                } .toolbar {
                    Button {
                        global.toggle()
                    } label: {
                        if global {
                            Text("Global").foregroundColor(.white)
                            Image(systemName: "globe").foregroundColor(.white)
                        } else {
                            Text("Private").foregroundColor(.white)
                            Image(systemName: "person").foregroundColor(.white)
                        }
                    }.onChange(of: global) { newValue in
                        setUsers(global: newValue)
                    }
                }.padding(20)
                    .navigationTitle("Leaderboard")
                    .navigationDestination(for: User.self) { user in
                        DetailUserView(user: user)
                    }
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbarBackground(
                        Color.purple,
                        for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
            }/*.onAppear(){
              sortUsers(timeFrame: selectedTimeFrame)
              }*/.task {
                  firestoreViewModel.getAllUsers()
                  // TODO: sorting
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

struct RankingItemView: View {
    var user : User
    var selectedTimeFrame : TimeFrame
    var position : Int
    
    var body: some View {
        
        GeometryReader {  geometry in
            HStack(spacing: 20) {
                
                Image(user.image ?? "user")
                    .resizable()
                    .frame(width: geometry.size.width/6, height: geometry.size.width/6)
                    .mask(Circle())
                
                VStack(alignment: .leading){
                    Text(user.username ?? user.email)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    HStack{
                        Image(systemName: "flame")
                        Text("1000").font(.footnote)
                        Image(systemName: "figure.walk")
                        Text("1000").font(.footnote)
                        
                    }
                    
                }.frame( width: geometry.size.width/3 , height: 50)
                
                VStack(){
                    
                    HStack{
                        Text("Score: ")
                            .font(.body)
                            .fontWeight(.bold)
                        Text(selectedTimeFrame == .daily ? "\(user.daily_score ?? 0)" : "\(user.weekly_score ?? 0)")
                            .font(.body)
                    }
                    
                    Spacer()
                    
                    HStack(){
                        Text("\(position)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("⏷")
                    }
                    
                }.frame(width: geometry.size.width/3.8,height: 50)
                
            }.padding(.vertical,10)
                .frame(maxWidth: .infinity,minHeight: 100)
                .background(ItemColor(number:position).opacity(0.65))
                .foregroundColor(.white)
                .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        
    }
}

func ItemColor(number : Int ) -> Color {
        let colors: [Color] = [.red, .green, .blue, .orange, .yellow, .purple, .pink, .gray, .black]
        return colors[number % 9]
}


struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView(firestoreViewModel: FirestoreViewModel())
    }
}



