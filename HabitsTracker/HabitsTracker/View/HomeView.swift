//
//  HomeView.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 20/11/22.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var healthViewModel: HealthViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State private var device : Device = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
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
        .onAppear(){
            isLandscape = orientationInfo.orientation == .landscape
            width = UIScreen.main.bounds.width
        }
        .onChange(of: orientationInfo.orientation) { orientation in
            isLandscape = orientation == .landscape
            width = UIScreen.main.bounds.width
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
        
                Spacer()
                
                NavigationLink {
                    RequestListView( firestoreViewModel:firestoreViewModel)
                } label: {
                    let numberOfRequests = firestoreViewModel.requests.count
                    if numberOfRequests != 0 {
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
                }
            }.padding(.horizontal,15)
            
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 1)
                .foregroundColor(.white.opacity(0.5))
                .shadow(color:.black,radius: 5)
            
            Text("Scores")
                .font(.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            
            if let user = firestoreViewModel.firestoreUser{
                if isLandscape{
                    ScoreRingView(dailyScore: healthViewModel.dailyScore ,weeklyScore: user.dailyScores[7],ringSize: width/2.3)
                        .padding(.top)
                }
                else {
                    ScoreRingView(dailyScore: healthViewModel.dailyScore ,weeklyScore: user.dailyScores[7],ringSize: width/1.7)
                        .padding(.top)
                }
            }
            
            if isLandscape{
                WaveView(upsideDown: false,repeatAnimation: false, base: 40, amplitude: 110)
                    .offset(y:20)
                    
            } else {
                WaveView(upsideDown: false,repeatAnimation: device == .iPhone ? true : false, base: 40, amplitude: 110)
                    .offset(y:20)
                
            }
            
            VStack{
                Text("Recent Activities")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(alignment:.center, spacing: 10) {
                    ForEach( ExtendedActivity.allActivities(), id: \.self) { activity in
                        if let baseActivity = healthViewModel.allMyTypes.first(where: { $0.id == activity.id }) {
                            ActivityStatusView(
                                activityType: activity.name,
                                quantity: baseActivity.quantity ?? 0,
                                score: healthViewModel.singleScore[activity.id] ?? 0,
                                image: activity.image,
                                measure: activity.measure,
                                width: getMaxWidth()
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
        GeneralView(healthViewModel: HealthViewModel(), authenticationViewModel: AuthenticationViewModel(),firestoreViewModel: FirestoreViewModel())
            .environmentObject(OrientationInfo())
    }
}
