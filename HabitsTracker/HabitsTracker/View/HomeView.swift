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
    
    var body: some View {
        NavigationStack{
            ZStack{
                RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    content
                }
            }
        }
    }
    
    var content: some View {
        
        VStack() {
            
            WaveView(upsideDown: false,repeatAnimation: true, base: 150, amplitude: 110)
            
            
            HStack{
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                NavigationLink {
                    RequestListView( firestoreViewModel:firestoreViewModel)
                } label: {
                    let numberOfRequests = 1 //firestoreViewModel.requests.count
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
                    
                    //}
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
                ScoreRingView(dailyScore: healthViewModel.dailyScore ,weeklyScore: user.dailyScores[7])
                    .padding(.bottom, 120)
            }
            
            
            VStack{
                Text("Recent Activities")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(20)
                
                VStack(alignment:.center) {
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
            }.background(Color("oxfordBlue"))
        }
        .padding(.top,20)
        
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView(healthViewModel: HealthViewModel(), authenticationViewModel: AuthenticationViewModel(),firestoreViewModel: FirestoreViewModel())
    }
}
