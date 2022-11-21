//
//  Home.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 19/11/22.
//

import SwiftUI
import Firebase
import GoogleSignIn


struct GeneralView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            PlanningView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Planning")
                }
            Text("Leaderboard")
                .tabItem {
                    Image(systemName: "trophy")
                    Text("Leaderboard")
                }
            Text("Goals")
                .tabItem {
                    Image(systemName: "medal")
                    Text("Goals")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct GeneralView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView()
    }
}
