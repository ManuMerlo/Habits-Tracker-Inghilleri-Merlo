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
        /*NavigationStack {
         Text("Signed In")
         .navigationTitle("Habits Tracker")
         .toolbar {
         ToolbarItem {
         Button("Logout") {
         try? Auth.auth().signOut()
         GIDSignIn.sharedInstance.signOut()
         withAnimation(.easeInOut) {
         logStatus = false
         }
         }
         }
         }
         }*/
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            Text("Planning")
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
