import SwiftUI
import Firebase


struct GeneralView: View {
    @ObservedObject var healthViewModel: HealthViewModel
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    @State var textFieldValue: String = ""
    @State private var didAppear: Bool = false
    
    var body: some View {
        TabView {
            HomeView(healthViewModel: healthViewModel, firestoreViewModel: firestoreViewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            
            /*PlanningView()
             .tabItem {
             Image(systemName: "calendar")
             Text("Planning")
             }*/
            
            SearchFriendView(firestoreViewModel:firestoreViewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            
            LeaderboardView(firestoreViewModel: firestoreViewModel)
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy")
                }
            /*Text("Goals")
             .tabItem {
             Image(systemName: "medal")
             Text("Goals")
             }*/
            
            //TODO: authentication is need to reauthenticate the user before deleting the account
            SettingsView(authenticationViewModel: authenticationViewModel,firestoreViewModel : firestoreViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
            
        }
        .accentColor(.white)
        .task {
            healthViewModel.requestAccessToHealthData()
            //firestoreViewModel.getAllUsers()
        }.alert("Enter your name", isPresented: $firestoreViewModel.needUsername ) {
            
            Text("\(firestoreViewModel.firestoreUser?.email ?? "ciao")")
            
            TextField("Enter your name", text: $textFieldValue)
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
            
            Button("Save", action: {
                firestoreViewModel.modifyUser(
                    uid:  firestoreViewModel.firestoreUser!.id,
                    field: "username",
                    value: textFieldValue)
                firestoreViewModel.needUsername = false
            }
            )
        } message: {
            Text("To start using the app, you first need to set your username.")
        }
        .onChange(of: healthViewModel.allMyTypes, perform: { _ in
            healthViewModel.computeSingleScore()
            healthViewModel.computeTotalScore()
            if var records = firestoreViewModel.firestoreUser?.records {
                print("updating records")
                if healthViewModel.updateRecords(records: &records) {
                    firestoreViewModel.modifyUser(
                        uid: firestoreViewModel.firestoreUser!.id,
                        field: "records",
                        records: records
                    )
                }
            }
        })
        .onChange(of: healthViewModel.dailyScore, perform: { newValue in
            // FIXME: FirestoreUser non dovrebbe essere = nil
            if let user = firestoreViewModel.firestoreUser {
                firestoreViewModel.updateDailyScores(uid: user.id, newScore: newValue)

            }
        })
        .onAppear() {
            firestoreViewModel.getCurrentUser()
            firestoreViewModel.getFriendsSubcollection()
            UITabBar.appearance().barTintColor = UIColor(red: 0.1, green: 0.15, blue: 0.23, alpha: 0.9)
        }
        .onDisappear() {
            firestoreViewModel.removeListenerForFriendsSubcollection()
            firestoreViewModel.removeListenerForCurrentUser()
            firestoreViewModel.cancelTasks()
            authenticationViewModel.cancelTasks()
        }
    }
}

struct GeneralView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView(healthViewModel: HealthViewModel(), authenticationViewModel: AuthenticationViewModel(), firestoreViewModel: FirestoreViewModel())
    }
}
