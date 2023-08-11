//
//  HomeView.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 20/11/22.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var healthViewModel: HealthViewModel
    @ObservedObject var firestoreViewModel : FirestoreViewModel
    
    var body: some View {
        NavigationStack{
            ScrollView(.vertical, showsIndicators: false) {
                content
            }
        }
    }
    
    var content: some View {
        
            VStack(alignment: .leading, spacing: 0) {
                HStack{
                    Text("Home")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    
                    Spacer()
                    
                    NavigationLink {
                        RequestListView( firestoreViewModel:firestoreViewModel)
                    } label: {
                        /*if let friends = firestoreViewModel.firestoreUser?.friends {
                            let numberOfRequests = friends.reduce(0) { result, friend in
                                return friend.status == "Request" ? result + 1 : result
                            }*/
                        let numberOfRequests = firestoreViewModel.requests.count
                            if numberOfRequests != 0 {
                                ZStack{
                                    Image(systemName: "heart")
                                        .foregroundColor(.black)
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
                

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(0 ..< 3) { item in
                            VCard()
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 10)
                }
                HStack{
                    Text("Recent activities ")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                    Spacer()
                    
                    Text("\(healthViewModel.dailyScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Image(systemName: "star.leadinghalf.filled")
                        .foregroundColor(.yellow)
                        .font(.system(size: 25))
                       
                    
                }.padding(.trailing)
                
                VStack(spacing: 20) {
                    //HCard(activityType: "Steps", quantity: healthViewModel.allMyTypes, image: "figure.walk")
                    ForEach( ExtendedActivity.allActivities(), id: \.self) { activity in
                        if let baseActivity = healthViewModel.allMyTypes.first(where: { $0.id == activity.id }) {
                            HCard(
                                activityType: activity.name,
                                quantity: baseActivity.quantity ?? 0,
                                score: healthViewModel.singleScore[activity.id] ?? 0,
                                image: activity.image
                            )
                        }
                    }
                }
                .padding(20)
            }
            .padding(.top,20)

    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView(healthViewModel: HealthViewModel(), authenticationViewModel: AuthenticationViewModel(),firestoreViewModel: FirestoreViewModel())
    }
}
