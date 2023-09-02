import SwiftUI
import Firebase


struct GeneralView: View {
    @ObservedObject var healthViewModel: HealthViewModel
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    @State private var device: Device = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    @State var textFieldValue: String = ""
    @State private var didAppear: Bool = false
    @State private var showAlerErrorUserRetrival: Bool = false
    
    var body: some View {
        Group {
            if var currentUser = firestoreViewModel.firestoreUser {
                TabView {
                    HomeView(healthViewModel: healthViewModel, firestoreViewModel: firestoreViewModel)
                        .tabItem {
                            Label("Dashboard", systemImage: "house")
                        }
                        .accessibilityIdentifier("HomeView")
                    
                    SearchFriendView(firestoreViewModel:firestoreViewModel)
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }.accessibilityIdentifier("SearchFriendView")
                    
                    
                    LeaderboardView(firestoreViewModel: firestoreViewModel)
                        .tabItem {
                            Label("Leaderboard", systemImage: "trophy")
                        }.accessibilityIdentifier("LeaderboardView")
                    
                    PointOfInterestView()
                        .tabItem {
                            Label("Map", systemImage: "map")
                        }.accessibilityIdentifier("MapView")
                    
                    //TODO: authentication is need to reauthenticate the user before deleting the account
                    SettingsView(authenticationViewModel: authenticationViewModel,firestoreViewModel : firestoreViewModel)
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }.accessibilityIdentifier("SettingsView")
                }
                .accentColor(.white)
                .task {
                    if device == .iPhone {
                        healthViewModel.requestAccessToHealthData()
                    }
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
                .onChange(of: healthViewModel.allMyTypes, perform: { _ in
                    if device == .iPhone{
                        healthViewModel.computeSingleScore()
                        healthViewModel.computeTotalScore()
                        print("updating records")
                        if healthViewModel.updateRecords(records: &(currentUser.records)) {
                            firestoreViewModel.modifyUser(
                                uid: currentUser.id,
                                field: "records",
                                newScores: currentUser.records
                            )
                        }
                        firestoreViewModel.modifyUser(uid: currentUser.id, field: "actualScores", newScores: healthViewModel.allMyTypes)
                    }
                    
                })
                .onChange(of: healthViewModel.dailyScore, perform: { newValue in
                    if device == .iPhone {
                        firestoreViewModel.updateDailyScores(uid: currentUser.id, newScore: newValue)
                    }
                })
                .onAppear() {
                    firestoreViewModel.addListenerForFriendsSubcollection()
                    if device == .iPhone {
                        healthViewModel.computeSingleScore()
                        healthViewModel.computeTotalScore()
                        print("updating records")
                        if healthViewModel.updateRecords(records: &(currentUser.records)) {
                            firestoreViewModel.modifyUser(
                                uid: currentUser.id,
                                field: "records",
                                newScores: currentUser.records
                            )
                        }
                        firestoreViewModel.modifyUser(uid: currentUser.id, field: "actualScores", newScores: healthViewModel.allMyTypes)
                        firestoreViewModel.updateDailyScores(uid: currentUser.id, newScore: healthViewModel.dailyScore)
                    }
                    
                    UITabBar.appearance().barTintColor = UIColor(red: 0.1, green: 0.15, blue: 0.23, alpha: 0.9)
                }
                .onDisappear() {
                    firestoreViewModel.removeListenerForFriendsSubcollection()
                    firestoreViewModel.cancelTasks()
                    authenticationViewModel.cancelTasks()
                }
            } else {
                LoadingView()
                    .accessibilityIdentifier("LoadingView")
            }
        }.onAppear{
            firestoreViewModel.addListenerForCurrentUser { error in
                if let error = error as? DBError, error == .failedUserRetrieval{
                    showAlerErrorUserRetrival.toggle()
                }
            }
        }.onDisappear{
            firestoreViewModel.removeListenerForCurrentUser()
        }.alert("Error", isPresented: $showAlerErrorUserRetrival ) {
            Button("Ok", action: {
                authenticationViewModel.logout()
            }
            )
        } message: {
            Text("An error occurred during user data recovery. Please try again later.")
        }
    }
}



struct GeneralView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView(healthViewModel: HealthViewModel(), authenticationViewModel: AuthenticationViewModel(), firestoreViewModel: FirestoreViewModel())
    }
}
