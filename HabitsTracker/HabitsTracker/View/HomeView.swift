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
                        .padding(.vertical,30)
                }.edgesIgnoringSafeArea(.horizontal)
                
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
        VStack(spacing: 0) {
            
            HStack{
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                
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
            }
            
            Divider()
                .background(Color("platinum"))
                .shadow(color: .black, radius: 1, x: 0, y: 0)
                .padding(.bottom)
            
            Text("Scores")
                .font(.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
            
            if let user = firestoreViewModel.firestoreUser{
                ScoreRingView(dailyScore: healthViewModel.dailyScore ,weeklyScore: user.dailyScores[7],ringSize: width/2)
            }
            
            WaveView(upsideDown: false,repeatAnimation:true, base: 100, amplitude: 110)
            
            VStack{
                Text("Recent Activities")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical,20)
                
                VStack(alignment:.center, spacing: 15) {
                    ForEach( ExtendedActivity.allActivities(), id: \.self) { activity in
                        if let baseActivity = healthViewModel.allMyTypes.first(where: { $0.id == activity.id }) {
                            ActivityStatusView(
                                activityType: activity.name,
                                quantity: baseActivity.quantity ?? 0,
                                score: healthViewModel.singleScore[activity.id] ?? 0,
                                image: activity.image,
                                measure: activity.measure
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
            
        }.padding(.top, 20)
        
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
