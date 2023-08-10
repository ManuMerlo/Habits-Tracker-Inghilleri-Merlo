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
    @ObservedObject var firestoreViewModel : FirestoreViewModel
    
    @State var textFieldValue: String = ""
    
    var body: some View {
        TabView {
            HomeView(healthViewModel: healthViewModel, firestoreViewModel: firestoreViewModel)
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
            
            Text("\(firestoreViewModel.firestoreUser?.email ?? "ciao")")
            
            TextField("Enter your name", text: $textFieldValue)
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
            
            Button("Save", action: {
                firestoreViewModel.modifyUser(
                    uid:  firestoreViewModel.firestoreUser!.id!,
                    field: "username",
                    value: textFieldValue,
                    type: "String")
                firestoreViewModel.needUsername = false
                
            }
            )
        } message: {
            Text("To start using the app, you first need to set your username.")
        }
        .onChange(of: firestoreViewModel.friendsSubcollection) { _ in
            DispatchQueue.global().async {
                firestoreViewModel.getFriends()
                DispatchQueue.main.async {
                    firestoreViewModel.getRequests()
                    DispatchQueue.main.async {
                        firestoreViewModel.getWaitingList()
                    }
                }
            }
        }
        .onChange(of: healthViewModel.allMyTypes, perform: { _ in
            healthViewModel.computeSingleScore()
            healthViewModel.computeTotalScore()
        })
        .onChange(of: healthViewModel.dailyScore, perform: { newValue in
            firestoreViewModel.updateDailyScores(uid: firestoreViewModel.firestoreUser!.id!, newScore: newValue)
        })
        .onAppear{
            firestoreViewModel.getCurrentUser()
            firestoreViewModel.getFriendsSubcollection()
        }
    }
}

struct GeneralView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView(healthViewModel: HealthViewModel(), authenticationViewModel: AuthenticationViewModel(), firestoreViewModel: FirestoreViewModel())
    }
}
