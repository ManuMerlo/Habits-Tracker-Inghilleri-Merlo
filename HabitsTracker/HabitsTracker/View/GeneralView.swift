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
    @StateObject var firestoreViewModel: FirestoreViewModel
    
    @State var textFieldValue: String = ""
    
    
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
            
            //TODO: authentication is need to reauthenticate the user before deleting the account
            SettingsView(authenticationViewModel: authenticationViewModel,firestoreViewModel : firestoreViewModel)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .task {
            healthViewModel.requestAccessToHealthData()
            firestoreViewModel.getAllUsers()
        }.alert("Enter your name", isPresented: $firestoreViewModel.needUsername ) {
            TextField("Enter your name", text: $textFieldValue)
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
            
            Button("Save", action: {
                firestoreViewModel.firestoreUser?.setUsername(name: textFieldValue)
                firestoreViewModel.modifyUser(
                    uid:  firestoreViewModel.firestoreUser!.id!,
                    field: "username",
                    value: textFieldValue,
                    type: "String")
                firestoreViewModel.needUsername.toggle()
            }
        )
        } message: {
            Text("To start using the app, you first need to set your username.")
        }
    }
}

struct GeneralView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView(healthViewModel: HealthViewModel(), authenticationViewModel: AuthenticationViewModel(), firestoreViewModel: FirestoreViewModel(uid:nil))
    }
}
