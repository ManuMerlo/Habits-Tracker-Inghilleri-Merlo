//
//  HomeView.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 20/11/22.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var healthViewModel: HealthViewModel
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            content
        }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Home")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0 ..< 3) { item in
                        VCard()
                    }
                }
                .padding(20)
                .padding(.bottom, 10)
            }
            Text("Recent activities")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
            
            VStack(spacing: 20) {
                //HCard(activityType: "Steps", quantity: healthViewModel.allMyTypes, image: "figure.walk")
                ForEach(Activity.allActivities()) { activity in
                    HCard(activityType: activity.name, quantity: healthViewModel.allMyTypes[activity.id] ?? "not found", image: activity.image)
                }
            }
            .padding(20)
        }
        .padding(.top,20)
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView(healthViewModel: HealthViewModel(), authenticationViewModel: AuthenticationViewModel())
    }
}
