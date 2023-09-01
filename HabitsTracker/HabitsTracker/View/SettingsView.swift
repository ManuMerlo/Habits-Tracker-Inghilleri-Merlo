import SwiftUI
import Firebase
import UserNotifications

struct SettingsView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    @StateObject var settingsViewModel = SettingsViewModel()
    
    @State var showAlert: Bool = false
    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State private var device : Device = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    @State var width = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(alignment: .center,spacing: 15){
                    ZStack(alignment: .top){
                        WaveView(upsideDown: true,repeatAnimation: false, base: isLandscape ? 250 : 280, amplitude: 70)
                        
                        VStack{
                            ProfileImageView(
                                path: firestoreViewModel.firestoreUser?.image,
                                systemName: "person.circle.fill",
                                size: 90,
                                color: .gray)
                            
                            Text("\( firestoreViewModel.firestoreUser?.username ?? "User")")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .accessibilityIdentifier("SettingsTitle")
                            
                            Text("\( firestoreViewModel.firestoreUser?.email ?? "")")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .accentColor(.white)
                                .padding(.bottom,30)
                            
                        }.padding(.top,isLandscape ? 30 : 60)
                    }
                    
                    List {
                        Section() {
                            
                            NavigationLink {
                                SecuritySettingsView(authenticationViewModel: authenticationViewModel, firestoreViewModel: firestoreViewModel)
                            } label: {
                                Label("Security Settings", systemImage: "lock")
                                
                            }
                            NavigationLink {
                                ModifyProfileView(firestoreViewModel: firestoreViewModel, settingsViewModel: settingsViewModel)
                            } label: {
                                Label("Modify profile", systemImage: "person")
                            }
                            
                            NavigationLink {
                                ProvidersDetailView(authenticationViewModel: authenticationViewModel)
                            } label: {
                                Label("Providers", systemImage: "person.crop.circle.badge.plus")
                            }
                            
                            NavigationLink {
                                NotificationDetailView(settingsViewModel: settingsViewModel)
                            } label: {
                                Label("Notifications", systemImage: "bell")
                            }
                            
                        }
                        .listRowBackground(Color("oxfordBlue"))
                        .listRowSeparatorTint(.white.opacity(0.8))
                        .foregroundColor(.white.opacity(0.8))
                        
                        Button{
                            showAlert.toggle()
                        } label: {
                            Label("Delete Account", systemImage: "minus.circle")
                        }
                        .listRowBackground(Color("oxfordBlue"))
                        .listRowSeparatorTint(.white.opacity(0.8))
                        .foregroundColor(.red)
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Delete Account"),
                                message: Text("Deleting your account will delete all content and remove your information from the database."),
                                primaryButton: .default(
                                    Text("Cancel")
                                ),
                                secondaryButton: .destructive(
                                    Text("Continue"),
                                    action:
                                        {
                                            guard let uid =  firestoreViewModel.firestoreUser?.id else{
                                                print("Null uid before deleting a user")
                                                return
                                            }
                                            
                                            Task {
                                                do {
                                                    try await firestoreViewModel.deleteUserData(uid: uid)
                                                    firestoreViewModel.firestoreUser = nil
                                                    authenticationViewModel.user = nil
                                                    try await authenticationViewModel.deleteUser()
                                                    // FIXME: can it be avoided?
                                                    authenticationViewModel.clearSignUpParameter()
                                                    authenticationViewModel.clearSignInParameter()
                                                } catch {
                                                    print(error.localizedDescription)
                                                }
                                            }
                                            
                                        }
                                )
                            )
                        }
                        Button{
                            authenticationViewModel.logout()
                            firestoreViewModel.firestoreUser = nil
                        } label: {
                            Label("Logout", systemImage: "pip.exit")
                                .foregroundColor(.blue)
                        }.listRowBackground(Color("oxfordBlue"))
                        
                    }
                    .frame(width: isLandscape ? width/1.5 : width/1.1, height: 370)
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .padding(.top,20)
                }
                
                
            }
            .accessibilityIdentifier("SettingsScrollView")
            .ignoresSafeArea()
            .background(RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500).opacity(1))
            
        }
        .onAppear(){
            isLandscape = orientationInfo.orientation == .landscape
            width = UIScreen.main.bounds.width
        }
        .onChange(of: orientationInfo.orientation) { orientation in
            isLandscape = orientation == .landscape
            width = UIScreen.main.bounds.width
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(authenticationViewModel: AuthenticationViewModel(),firestoreViewModel : FirestoreViewModel())
            .environmentObject(OrientationInfo())
    }
}


