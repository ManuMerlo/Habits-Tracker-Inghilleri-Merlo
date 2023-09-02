import SwiftUI

struct HomeView: View {
    @ObservedObject var healthViewModel: HealthViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    @State private var numberOfRequests: Int = 0
    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State private var device: Device = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    @State var width = UIScreen.main.bounds.width
    
    @State var waveCoordinate : CGFloat = 0
    
    var body: some View {
        NavigationStack{
            ZStack{
                RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    content()
                }
                .edgesIgnoringSafeArea(.horizontal)
            }
        }
        .refreshable {
            self.numberOfRequests = firestoreViewModel.getFriendsIdsWithStatus(status: FriendStatus.Request).count
        }
        .onAppear(){
            self.numberOfRequests = firestoreViewModel.getFriendsIdsWithStatus(status: FriendStatus.Request).count
            isLandscape = orientationInfo.orientation == .landscape
            width = UIScreen.main.bounds.width
        }
        .onChange(of: orientationInfo.orientation) { orientation in
            isLandscape = orientation == .landscape
            width = UIScreen.main.bounds.width
        }.onChange(of: firestoreViewModel.friendsSubcollection) { newValue in
            self.numberOfRequests = firestoreViewModel.getFriendsIdsWithStatus(status: FriendStatus.Request).count
        }
    }
    
    @ViewBuilder
    func content() -> some View {
        VStack(spacing: 15) {
            HStack{
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("HomeTitle")
        
                Spacer()
                
                NavigationLink {
                    RequestListView(firestoreViewModel:firestoreViewModel)
                } label: {
                    if numberOfRequests > 0 {
                        ZStack{
                            Image(systemName: "heart")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                                .padding(.trailing, 10)
                            
                            Text("\(numberOfRequests)")
                                .foregroundColor(.white)
                                .font(.custom("Open Sans", size: 18))
                                .padding(4)
                                .background(Circle().foregroundColor(.red))
                                .offset(x: -20, y: -10)
                        }
                        
                    }
                }.accessibilityIdentifier("heartButton")
            }.padding(.horizontal,15)
            
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 1)
                .foregroundColor(.white.opacity(0.5))
                .shadow(color:.black,radius: 5)
            
            Text("Scores")
                .font(.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            
            if let user = firestoreViewModel.firestoreUser {
                let today = (Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
                if isLandscape{
                    ScoreRingView(dailyScore: user.dailyScores[today], weeklyScore: user.dailyScores[7], ringSize: width/2.3)
                        .padding(.top)
                }
                else {
                    ScoreRingView(dailyScore: user.dailyScores[today], weeklyScore: user.dailyScores[7], ringSize: width/1.7)
                        .padding(.top)
                }
            }

            WaveView(upsideDown: false, repeatAnimation: false, base: 40, amplitude: 110)
                    .offset(y:20)

            VStack{
                Text("Recent Activities")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(alignment:.center, spacing: 10) {
                    ForEach(ExtendedActivity.allActivities(), id: \.self) { activity in
                        if let currentUser = firestoreViewModel.firestoreUser, let baseActivity = currentUser.actualScores.first(where: { $0.id == activity.id }) {
                            ActivityStatusView(
                                activityType: activity.name,
                                quantity: baseActivity.quantity ?? 0,
                                score: healthViewModel.singleScore[activity.id] ?? 0,
                                image: activity.image,
                                measure: activity.measure,
                                width: getMaxWidth(),
                                record: max ( currentUser.records.first(where: { $0.id == activity.id })?.quantity ?? 0, getMinQuantity(activity: activity.id))
                            )
                        }
                    }
                }
                .frame(maxWidth: getMaxWidth())
                
                if let user = firestoreViewModel.firestoreUser {
                    let elementsize =  (getMaxWidth()-15)/2
                    RecordView(user: user, elementSize: elementsize)
                        .frame(maxWidth: getMaxWidth())
                        .padding(.bottom,20)
                }
            }
            .background(Color("oxfordBlue"))
        }
        .padding(.top, 30)
    }
    
    func getMinQuantity(activity : String ) -> Int {
        switch activity {
        case "activeEnergyBurned":
            return 200
        case "appleExerciseTime":
            return 45
        case "appleStandTime":
            return 8
        case "distanceWalkingRunning":
            return 10
        case "stepCount":
            return 2000
        case "distanceCycling":
            return 2
        default:
            return 300
        }
    }
    
    func getMaxWidth() -> CGFloat{
        if device == .iPad {
            if isLandscape {
                return width / 1.5
            } else {
                return width / 1.3
            }
        } else if device == .iPhone {
            if isLandscape {
                return width/1.4
            } else {
                return width/1.1
            }
        }
        return width
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(healthViewModel: HealthViewModel(),firestoreViewModel: FirestoreViewModel())
            .environmentObject(OrientationInfo())
    }
}
