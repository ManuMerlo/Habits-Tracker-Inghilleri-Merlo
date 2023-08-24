import SwiftUI
import FirebaseFirestoreSwift

struct LeaderboardView: View {
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    //FIXME: merge refactor
    @StateObject var leaderboardViewModel = LeaderBoardViewModel()
    
    @State private var global : Bool = true
    @State private var selectedTimeFrame : TimeFrame = .daily
    @State var users: [User] = []
    
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State var width = UIScreen.main.bounds.width
    
    // TODO: it is a listener, check how to do the cancellation
    @FirestoreQuery(
        collectionPath: "users"
    ) var globalUsers: [User]
    
    init(firestoreViewModel: FirestoreViewModel) {
        self.firestoreViewModel = firestoreViewModel
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(red: 0.1, green: 0.15, blue: 0.23, alpha: 0.9)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    }
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 15){
                    Picker("Choose a time frame", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases,id: \.self){
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedTimeFrame , perform: { newValue in
                        users = leaderboardViewModel.sortUsers(users:users, timeFrame: newValue)
                    })
                    .frame(width : isLandscape ? width/1.5 : width/1.1)
                    
                    ScrollView {
                        VStack(spacing: 10){
                            ForEach(users, id: \.self) { user in
                                NavigationLink(value: user){
                                    RankingItemView(leaderboardViewModel: leaderboardViewModel,
                                                    firestoreViewModel: firestoreViewModel,
                                                    user : user,
                                                    selectedTimeFrame: selectedTimeFrame,
                                                    global:global,
                                                    position: ((users.isEmpty ? globalUsers : users).firstIndex(of: user) ?? 0) + 1,
                                                    width : isLandscape ? width/1.5 : width/1.2
                                    ).frame(width : isLandscape ? width/1.5 : width/1.1)
                                }
                            }
                        }
                    }
                }
                .padding(.top,15)
                .toolbar {
                    Button {
                        global.toggle()
                    } label: {
                        Text(global ? "Global" : "private").foregroundColor(.white)
                        Image(systemName: global ? "globe" : "person").foregroundColor(.white)
                    }.onChange(of: global) { newValue in
                        users = global ? globalUsers : globalUsers.filter({ friend in
            firestoreViewModel.getFriendsIdsWithStatus(status: FriendStatus.Confirmed).contains(friend.id)
        })
                        users = leaderboardViewModel.sortUsers(users: users,timeFrame: selectedTimeFrame)
                    }
                }
                .navigationTitle("Leaderboard")
                .navigationDestination(for: User.self) { user in
                    UserProfileView(firestoreViewModel: firestoreViewModel, user: user)
                }
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(
                    Color("oxfordBlue"),
                    for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
            }
        }
        .onAppear{
            users = global ? globalUsers : globalUsers.filter({ friend in
            firestoreViewModel.getFriendsIdsWithStatus(status: FriendStatus.Confirmed).contains(friend.id)
        })
            users = leaderboardViewModel.sortUsers(users: users,timeFrame: selectedTimeFrame)
            isLandscape = orientationInfo.orientation == .landscape
            width = UIScreen.main.bounds.width
            
        }.onChange(of: globalUsers) { newValue in
            users = global ? globalUsers : globalUsers.filter({ friend in
            firestoreViewModel.getFriendsIdsWithStatus(status: FriendStatus.Confirmed).contains(friend.id)
        })                users = leaderboardViewModel.sortUsers(users: users,timeFrame: selectedTimeFrame)
            
        }
        .onChange(of: orientationInfo.orientation) { orientation in
            isLandscape = orientation == .landscape
            width = UIScreen.main.bounds.width
        }
    }
}

enum TimeFrame: String, CaseIterable {
    case weekly = "Weekly"
    case daily = "Daily"
}


struct RankingItemView: View {
    //FIXME: merge refactor i viewmodels dovrebbero essere observedobject, no?
    var leaderboardViewModel : LeaderBoardViewModel
    var firestoreViewModel : FirestoreViewModel
    var user : User
    var selectedTimeFrame : TimeFrame
    var global : Bool
    var position : Int
    var width : CGFloat
    let today = ( Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    
    var body: some View {
        
        HStack(spacing: 15) {
            ZStack(alignment: .center){
                ProfileImageView(path: user.image, size: 50, color: .white)
                ZStack{
                    Circle()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                    Text("\(position)")
                        .foregroundColor(.black)
                        .font(.custom("Open Sans", size: 18))
                }.offset(x:-25,y: -25)
            }.frame(maxWidth: width/5)
            
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 1)
                .foregroundColor(.white.opacity(0.5))
                .shadow(color:.black,radius: 5)
            
            VStack(alignment: .leading, spacing: 15){
                Text(user.username ?? user.email)
                    .font(.custom("Open Sans", size: 21))
                    .fontWeight(.bold)
                
                HStack{
                    Image(systemName: "flame")
                    Text("100")
                        .font(.footnote)
                    Image(systemName: "figure.walk")
                    Text("100")
                        .font(.footnote)
                }
                
            }.frame(width:width/3, height: 70, alignment: .leading)
            
            Spacer()
            
            VStack(alignment: .center,spacing: 15){
                Text("Score")
                    .font(.custom("Open Sans", size: 21))
                
                Text(selectedTimeFrame == .daily ? "\(user.dailyScores[today])" : "\(user.dailyScores[7])")
                    .font(.body)
                
            }.frame( width: width/5, height: 70)
            
        }
        .padding(.vertical,10)
        .padding(.horizontal,20)
        .background(ItemColor(number:position).opacity(0.65))
        .foregroundColor(.white)
        .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onChange(of: position) { newPosition in
            if(user.id == firestoreViewModel.firestoreUser!.id!){
                switch (selectedTimeFrame, global) {
                case (.daily, true):
                    if let oldPosition = user.dailyGlobal, oldPosition < newPosition {
                        print("oldposition \(oldPosition)")
                        print("newPosition \(newPosition)")
                        leaderboardViewModel.sendPositionChangeNotification()
                    }
                    firestoreViewModel.modifyUser(uid: user.id!, field: "dailyGlobal", value: newPosition)
                case (.daily, false):
                    if let oldPosition = user.dailyPrivate, oldPosition < newPosition{
                        leaderboardViewModel.sendPositionChangeNotification()
                    }
                    firestoreViewModel.modifyUser(uid: user.id!, field: "dailyPrivate", value: newPosition)
                case (.weekly, true):
                    if let oldPosition = user.weeklyGlobal, oldPosition < newPosition{
                        leaderboardViewModel.sendPositionChangeNotification()
                    }
                    firestoreViewModel.modifyUser(uid: user.id!, field: "weeklyGlobal", value: newPosition)
                case (.weekly, false):
                    if let oldPosition = user.weeklyPrivate, oldPosition < newPosition{
                        leaderboardViewModel.sendPositionChangeNotification()
                    }
                    firestoreViewModel.modifyUser(uid: user.id!, field: "weeklyPrivate", value: newPosition)
                }
            }
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
            .environmentObject(OrientationInfo())
    }
}



