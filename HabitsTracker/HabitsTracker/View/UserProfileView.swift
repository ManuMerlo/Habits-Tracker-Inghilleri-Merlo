import SwiftUI
import Foundation
import Charts

struct UserProfileView: View {
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var user: User
    var today = (Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State private var device : Device = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    @State var width = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack{
            RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                .edgesIgnoringSafeArea(.all)
            VStack{
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
                                .frame(width: isLandscape ? width/1.7 : width/1.2)
                                .padding(.top, getMaxWidth() )
                                .padding(.bottom)
                            
                        }
                        content()
                            .frame(width: width/1.2)
                    }
                }
                .edgesIgnoringSafeArea(.top)
            }
        }
        .edgesIgnoringSafeArea(.horizontal)
        .navigationBarTitle("", displayMode: .inline) // Hide the title
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(
            Color("oxfordBlue"),
            for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear(){
            isLandscape = orientationInfo.orientation == .landscape
            width = UIScreen.main.bounds.width
        }
        .onChange(of: orientationInfo.orientation) { orientation in
            isLandscape = orientation == .landscape
            width = UIScreen.main.bounds.width
        }
        
    }
    
    func getMaxWidth() -> CGFloat {
        if device == .iPhone {
            return isLandscape ? 40 : 100
        } else {
            return 90
        }
    }
    
    @ViewBuilder
    func content() -> some View {
        VStack(alignment: .center,spacing: 15){
            Text("Today's Scores")
                .font(.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ScoreRingView(dailyScore: user.dailyScores[today],weeklyScore: user.dailyScores[7], ringSize: isLandscape ? width/2.5 : width/2)
                .padding(.vertical,15)
            
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 2)
                .foregroundColor(.white.opacity(0.7))
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
                }.environment(\.colorScheme, .dark)
                    .chartForegroundStyleScale([
                        "Current Week": Color(hue: 0.33, saturation: 0.81, brightness: 0.76),
                    ])
                    .chartYAxis {
                        AxisMarks(position: .leading)
                        
                    }
                    .frame(height: 250)
                    .padding(.horizontal,20)
                
            }
            
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 2)
                .foregroundColor(.white.opacity(0.7))
                .shadow(color:.black,radius: 5)
            
            RecordView(user: user, elementSize: (width/1.2-15)/2)
                .padding(.bottom,20)
            
        }
    }
    
    func getDayLabel(for index: Int) -> String {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return days[index % days.count]
    }
    
}

struct Header: View {
    
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var user: User
    var today = ( Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    
    var body: some View{
        VStack(alignment: .leading, spacing: 15){
            VStack{
                HStack {
                    
                    VStack(alignment: .leading,spacing: 10){
                        if let username = user.username{
                            Text(username)
                                .font(.custom("Open Sans", size: 30))
                                .foregroundColor(.white)
                            
                        } else {
                            Text("User")
                                .font(.custom("Open Sans", size: 30))
                                .foregroundColor(.white)
                            
                        }
                        
                        Text("\(user.email)")
                            .font(.custom("Open Sans", size: 15))
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "medal.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                            
                            Text("\(user.dailyScores[today]) points")
                                .font(.custom("Open Sans", size: 15))
                                .foregroundColor(.white)
                        }
                        
                    }
                    
                    Spacer()
                    
                    ProfileImageView(path:user.image, size: 70, color: .white)
                    
                }
                
            }
            
            if let firestoreUser = firestoreViewModel.firestoreUser, firestoreUser.id != user.id{
                ButtonRequest(firestoreViewModel: firestoreViewModel, user: user)
            }
            
        }
        
    }
    
}


struct ButtonRequest: View {
    
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    var user: User
    
    var body: some View {
        
        HStack {
            
            Button(action: {
                if firestoreViewModel.getFriendStatus(friendId: user.id) == FriendStatus.Waiting || firestoreViewModel.getFriendStatus(friendId: user.id) == FriendStatus.Confirmed {
                    firestoreViewModel.removeFriend(uid: firestoreViewModel.firestoreUser!.id, friendId: user.id)
                } else if firestoreViewModel.getFriendStatus(friendId: user.id) == FriendStatus.Request {
                    firestoreViewModel.confirmFriend(uid: firestoreViewModel.firestoreUser!.id, friendId: user.id)
                } else {
                    firestoreViewModel.addRequest(uid: firestoreViewModel.firestoreUser!.id, friendId: user.id)
                }
            }) {
                Image(systemName: buttonImageFor(user))
                Text(buttonTextFor(user))
                    .font(.custom("Open Sans", size: 18))
            }
            .buttonStyle(.borderedProminent)
            .foregroundColor(Color("oxfordBlue"))
            .tint(.white)
            
            if firestoreViewModel.getFriendStatus(friendId: user.id) == FriendStatus.Request {
                Button(action: {
                    firestoreViewModel.removeFriend(uid: firestoreViewModel.firestoreUser!.id, friendId: user.id)
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
        if firestoreViewModel.getFriendStatus(friendId: user.id) == FriendStatus.Waiting {
            return "Waiting"
        } else if firestoreViewModel.getFriendStatus(friendId: user.id) == FriendStatus.Confirmed {
            return "Friend"
        } else if firestoreViewModel.getFriendStatus(friendId: user.id) == FriendStatus.Request {
            return "Confirm"
        } else {
            return "Follow"
        }
    }
    
    private func buttonImageFor(_ user: User) -> String {
        if firestoreViewModel.getFriendStatus(friendId: user.id) == FriendStatus.Waiting {
            return "person.badge.clock.fill"
        } else if firestoreViewModel.getFriendStatus(friendId: user.id) == FriendStatus.Confirmed {
            return "checkmark.seal"
        } else if firestoreViewModel.getFriendStatus(friendId: user.id) == FriendStatus.Request {
            return "person.fill.badge.plus"
        } else {
            return "link"
        }
    }
    
}

@ViewBuilder
func VerticalText(upperText: String, lowerText:String) -> some View {
    VStack(alignment: .center){
        Text(upperText)
            .foregroundColor(.white)
            .font(.custom("Open Sans", size: 22))
            .padding(.bottom,1)
        Text(lowerText)
            .foregroundColor(.white)
            .font(.custom("Open Sans", size: 15))
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(firestoreViewModel: FirestoreViewModel(), user: User(
            id:"1234",
            email: "lulu@gmail.com",
            username: "lulu",
            birthDate: "10/08/2001",
            sex: Sex.Female,
            height: 150,
            weight: 60,
            image: "",
            dailyScores: [20,50,40,60,60,90,70,200,40])).environmentObject(OrientationInfo())
    }
}




