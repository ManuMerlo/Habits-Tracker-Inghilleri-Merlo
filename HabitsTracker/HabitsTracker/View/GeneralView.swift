import SwiftUI
import Firebase


struct GeneralView: View {
    @ObservedObject var healthViewModel: HealthViewModel
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    @State var textFieldValue: String = ""
    @State private var didAppear: Bool = false
    
    var body: some View {
        Group {
            if var currentUser = firestoreViewModel.firestoreUser {
                TabView {
                    HomeView(healthViewModel: healthViewModel, firestoreViewModel: firestoreViewModel)
                        .tabItem {
                            Label("Dashboard", systemImage: "house")
                        }
                    
                    SearchFriendView(firestoreViewModel:firestoreViewModel)
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                    
                    
                    LeaderboardView(firestoreViewModel: firestoreViewModel)
                        .tabItem {
                            Label("Leaderboard", systemImage: "trophy")
                        }
                    
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
                    
                    Text("\(currentUser.email)")
                    
                    TextField("Enter your name", text: $textFieldValue)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                    
                    Button("Save", action: {
                        firestoreViewModel.modifyUser(
                            uid:  currentUser.id,
                            field: "username",
                            value: textFieldValue)
                        firestoreViewModel.needUsername = false
                    }
                    )
                } message: {
                    Text("To start using the app, you first need to set your username.")
                }
                //FIXME: does not work
                .onChange(of: healthViewModel.allMyTypes, perform: { _ in
                    healthViewModel.computeSingleScore()
                    healthViewModel.computeTotalScore()
                    print("updating records")
                    if healthViewModel.updateRecords(records: &(currentUser.records)) {
                        firestoreViewModel.modifyUser(
                            uid: currentUser.id,
                            field: "records",
                            records: currentUser.records
                        )
                    }
                    
                })
                .onChange(of: healthViewModel.dailyScore, perform: { newValue in
                    firestoreViewModel.updateDailyScores(uid: currentUser.id, newScore: newValue)
                })
                .onAppear() {
                    //firestoreViewModel.addListenerForCurrentUser()
                    firestoreViewModel.addListenerForFriendsSubcollection()
                    
                    healthViewModel.computeSingleScore()
                    healthViewModel.computeTotalScore()
                    print("updating records")
                    if healthViewModel.updateRecords(records: &(currentUser.records)) {
                        firestoreViewModel.modifyUser(
                            uid: currentUser.id,
                            field: "records",
                            records: currentUser.records
                        )
                    }
                    firestoreViewModel.updateDailyScores(uid: currentUser.id, newScore: healthViewModel.dailyScore)
                    
                    UITabBar.appearance().barTintColor = UIColor(red: 0.1, green: 0.15, blue: 0.23, alpha: 0.9)
                }
                .onDisappear() {
                    firestoreViewModel.removeListenerForFriendsSubcollection()
                    firestoreViewModel.cancelTasks()
                    authenticationViewModel.cancelTasks()
                }
            } else {
                LoadingView()
            }
        }
        .onAppear{
            /*DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
             firestoreViewModel.addListenerForCurrentUser()
             }*/
            firestoreViewModel.addListenerForCurrentUser()
        }.onDisappear{
            firestoreViewModel.removeListenerForCurrentUser()
        }
        
        
    }
}



struct GeneralView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView(healthViewModel: HealthViewModel(), authenticationViewModel: AuthenticationViewModel(), firestoreViewModel: FirestoreViewModel())
    }
}
