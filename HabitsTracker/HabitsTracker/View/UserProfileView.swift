//
//  UserProfile.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 01/08/23.
//

import SwiftUI
import Foundation
import Charts

struct UserProfileView: View {
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var user: User
    var today = ( Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    
    var body: some View {
        ZStack{
            
            RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView (.vertical, showsIndicators: false) {
                
                VStack{
                    ZStack{
                        Color("oxfordBlue").overlay(alignment:.bottom) {
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(Color("oxfordBlue").opacity(0.7))
                                .shadow(color:.black,radius: 5)
                        }
                        
                        Header(firestoreViewModel: firestoreViewModel, user: user)
                    }.edgesIgnoringSafeArea(.top)
                    
                    
                    content(user: user).padding(.vertical)
                    
                    
                }.toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbarBackground(
                        Color("oxfordBlue"),
                        for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                
            }.navigationBarTitle("", displayMode: .inline) // Hide the title
        }
        
    }
    
}

struct Header: View{
    
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var user: User
    var today = ( Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    
    var body: some View{
        
        VStack{
            
            VStack(alignment: .leading){
                Spacer()
                HStack {
                    VStack(alignment: .leading){
                        if let username = user.username{
                            Text(username)
                                .font(.custom("Open Sans", size: 30))
                                .foregroundColor(.white)
                                .padding(.bottom,1)
                            
                            
                        } else {
                            Text("User")
                                .font(.custom("Open Sans", size: 30))
                                .foregroundColor(.white)
                                .padding(.bottom,1)
                            
                        }
                        
                        Text("\(user.email)")
                            .font(.custom("Open Sans", size: 15))
                            .foregroundColor(.white)
                            .padding(.bottom,3)
                        
                        HStack{
                            Image(systemName: "medal.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                            
                            Text("\(user.dailyScores[today]) points")
                                .font(.custom("Open Sans", size: 15))
                                .foregroundColor(.white)
                        }
                        
                    }
                    
                    Spacer()
                    
                    ProfileImageView(
                        size: 70 ,
                        color: .white)
                    
                }.padding(.bottom,5)
                
                Spacer()
                if let firestoreUser = firestoreViewModel.firestoreUser, firestoreUser.id! != user.id{
                    ButtonRequest(firestoreViewModel: firestoreViewModel, user: user)
                }
                
                Spacer()
                
                
            }
            .padding(.vertical)
            .frame(width: UIScreen.main.bounds.width/1.2)
            
        }
    }
    
}


struct ButtonRequest: View {
    
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var user: User
    
    var body :some View{
        
        HStack{
        
        Button(action: {
            if firestoreViewModel.waitingList.contains(user) || firestoreViewModel.friends.contains(user) {
                firestoreViewModel.removeFriend(uid: firestoreViewModel.firestoreUser!.id!, friend: user.id!)
                
            } else if firestoreViewModel.requests.contains(user) {
                firestoreViewModel.confirmFriend(uid: firestoreViewModel.firestoreUser!.id!, friendId: user.id!)
            } else {
                firestoreViewModel.addRequest(uid: firestoreViewModel.firestoreUser!.id!, friend: user.id!)
            }
        }) {
            Image(systemName: buttonImageFor(user))
            Text(buttonTextFor(user))
                .font(.custom("Open Sans", size: 18))
        }
        .buttonStyle(.borderedProminent)
        .foregroundColor(Color("oxfordBlue"))
        .tint(.white)
        
        if firestoreViewModel.requests.contains(user) {
            Button(action: {
                firestoreViewModel.removeFriend(uid: firestoreViewModel.firestoreUser!.id!, friend: user.id!)
            }) {
                Image(systemName: "person.fill.badge.minus")
                Text("Remove")
                    .font(.custom("Open Sans", size: 18))
            }
            .buttonStyle(.borderedProminent)
            .foregroundColor(Color("oxfordBlue"))
            .tint(.white)
        }
        
    }
        
    }
    private func buttonTextFor(_ user: User) -> String {
        if firestoreViewModel.waitingList.contains(user) {
            return "Waiting"
        } else if firestoreViewModel.friends.contains(user) {
            return "Friend"
        } else if firestoreViewModel.requests.contains(user) {
            return "Confirm"
        } else {
            return "Follow"
        }
    }
    
    private func buttonImageFor(_ user: User) -> String {
        if firestoreViewModel.waitingList.contains(user) {
            return "person.badge.clock.fill"
        } else if firestoreViewModel.friends.contains(user) {
            return "checkmark.seal"
        } else if firestoreViewModel.requests.contains(user) {
            return "person.fill.badge.plus"
        } else {
            return "link"
        }
    }
    
}

struct content: View {
    
    var user : User
    let gradientStart = Color(red: 239.0 / 255, green: 120.0 / 255, blue: 221.0 / 255)
    var today = ( Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    
    var body: some View {
        
        VStack(alignment: .center){
            
            Text("Todays Scores")
                .font(.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ScoreRingView(dailyScore: user.dailyScores[today],weeklyScore: user.dailyScores[7])
            
            
            
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 2)
                .foregroundColor(.white.opacity(0.7))
                .padding(.vertical)
                .shadow(color:.black,radius: 5)
            
            
            VStack(alignment: .center){
                Text("Score Trend")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Chart {
                    ForEach(user.dailyScores.indices[0...6], id: \.self) { index in
                        LineMark(
                            x: .value("Day", getDayLabel(for: index)),
                            y: .value("Score", user.dailyScores[index])
                        )
                        .foregroundStyle(
                            by: .value("Week", "Current Week")
                        )
                        .interpolationMethod(.catmullRom)
                        .symbol(
                            by: .value("Week", "Current Week")
                        )
                        .symbolSize(30)
                    }
                }.environment(\.colorScheme, .dark) //FIXME: temporary fix
                    .chartForegroundStyleScale([
                        "Current Week": Color(hue: 0.33, saturation: 0.81, brightness: 0.76),
                    ])
                    .chartYAxis {
                        AxisMarks(position: .leading)
                        
                    }
                    .frame(height: 250)
                    .padding(.horizontal,20)
                    .foregroundColor(.blue)
                
            }
            
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 2)
                .foregroundColor(.white.opacity(0.7))
                .padding(.vertical)
                .shadow(color:.black,radius: 5)
            
            RecordView(user: user)
            
        }.frame(width: UIScreen.main.bounds.width/1.1)
    }
    
    private func getDayLabel(for index: Int) -> String {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return days[index % days.count]
    }
}

@ViewBuilder
func VerticalText(upperText: String, lowerText:String) -> some View {
    VStack(alignment: .center){
        
        Text(upperText).foregroundColor(.white)
            .font(.custom("Open Sans", size: 22))
            .padding(.bottom,1)
        Text(lowerText).foregroundColor(.white)
            .font(.custom("Open Sans", size: 15))
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(firestoreViewModel: FirestoreViewModel(), user: User(
            username: "lulu",
            email: "lulu@gmail.com",
            birthDate: "10/08/2001",
            sex: Sex.Female,
            height: 150,
            weight: 60,
            image: "",
            dailyScores: [20,50,40,60,60,90,70,200,40]))
    }
}



