//TODO: da implementare
/*switch selectedTimeFrame {
 case .weekly:
 users = viewModel.weeklyUsers
 case .daily:
 users = viewModel.dailyUsers
 }*/

import SwiftUI
import FirebaseFirestoreSwift

struct LeaderboardView: View {
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    @State private var global : Bool = true
    @State private var selectedTimeFrame : TimeFrame = .daily
    @State var users: [User] = []
    let today = ( Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    
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
                
                VStack{
                    
                    Picker("Choose a time frame", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases,id: \.self){
                            Text($0.rawValue)
                            
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedTimeFrame , perform: { newValue in
                        sortUsers(timeFrame: newValue)
                    })
                    .padding(.bottom,8)
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(users, id: \.self) { user in
                                NavigationLink(value: user){
                                    RankingItemView(user : user,
                                                    selectedTimeFrame: selectedTimeFrame,
                                                    position: ((users.isEmpty ? globalUsers : users).firstIndex(of: user) ?? 0) + 1
                                    ).padding(.bottom, 95)
                                }
                            }
                        }
                    }.padding(.top,10)
                }
                .toolbar {
                    Button {
                        global.toggle()
                        setUsers(global: global)
                    } label: {
                        if !global {
                            Text("Global").foregroundColor(.white)
                            Image(systemName: "globe").foregroundColor(.white)
                        } else {
                            Text("Private").foregroundColor(.white)
                            Image(systemName: "person").foregroundColor(.white)
                        }
                    }
                }.padding(20)
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
        }.onAppear{
            sortUsers(timeFrame: selectedTimeFrame)
        }
        .onChange(of: globalUsers) { newValue in
            setUsers(global: global)
        }
    }
    
    func sortUsers(timeFrame: TimeFrame) {
            users.sort { user1, user2 in
                switch timeFrame {
                case .daily:
                    return user1.dailyScores[today] > user1.dailyScores[today]
                case .weekly:
                    return user1.dailyScores[7] > user2.dailyScores[7]
                }
            }
        }
    
    func setUsers( global: Bool){
        if global == true {
            users = globalUsers
        } else {
            //users = firestoreViewModel.friends
        }
        sortUsers(timeFrame: selectedTimeFrame)
    }
}

enum TimeFrame: String, CaseIterable {
    case weekly = "Weekly"
    case daily = "Daily"
}


struct RankingItemView: View {
    var user: User
    var selectedTimeFrame : TimeFrame
    var position : Int
    let today = ( Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    let screen = UIScreen.main.bounds.width
    
    var body: some View {
        
        GeometryReader {  geometry in
            HStack(spacing: 20) {
                ZStack{
                    
                    ProfileImageView(path: user.image, size: geometry.size.width/7, color: .white)
                    ZStack{
                        Circle()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.white)
                        Text("\(position)")
                            .foregroundColor(.black)
                            .font(.custom("Open Sans", size: 18))
                        
                    }.offset(x: -geometry.size.width/10, y: -geometry.size.width/13)
                    
                    
                }
                
                VStack(alignment: .leading){
                    Text(user.username ?? user.email)
                        .font(.custom("Open Sans", size: 21))
                        .fontWeight(.bold)
                    
                    Spacer()
                
                    HStack{
                        Image(systemName: "flame")
                        Text("100")
                            .font(.footnote)
                        Image(systemName: "figure.walk")
                        Text("100")
                            .font(.footnote)

                        
                    }
                    
                }.frame( width: geometry.size.width/3 , height: 50)
                
                VStack(alignment: .center){
                    Text("Score")
                        .font(.custom("Open Sans", size: 21))
                    
                    Spacer()
                    
                    Text(selectedTimeFrame == .daily ? "\(user.dailyScores[today])" : "\(user.dailyScores[7])")
                        .font(.body)
                    
                }.frame( width: geometry.size.width/4.5, height: 50)
                
                
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



