//
//  Home.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 19/11/22.
//

import SwiftUI
import Firebase
//import GoogleSignIn


struct GeneralView: View {
    @ObservedObject var healthViewModel: HealthViewModel
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel

    
    var body: some View {
        TabView {
            HomeView(healthViewModel: healthViewModel)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            /*PlanningView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Planning")
                }*/
            
            SearchFriendView(firestoreViewModel:firestoreViewModel)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            
            LeaderboardView(firestoreViewModel: firestoreViewModel)
                .tabItem {
                    Image(systemName: "trophy")
                    Text("Leaderboard")
                }
            /*Text("Goals")
                .tabItem {
                    Image(systemName: "medal")
                    Text("Goals")
                }*/
            SettingsView(authenticationViewModel: authenticationViewModel,firestoreViewModel : firestoreViewModel)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .task {
            healthViewModel.requestAccessToHealthData()
        }
    }
}

struct GeneralView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView(healthViewModel: HealthViewModel(), authenticationViewModel: AuthenticationViewModel(), firestoreViewModel: FirestoreViewModel())
    }
}
