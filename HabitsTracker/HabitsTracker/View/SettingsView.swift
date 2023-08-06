//
//  SettingsView.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 20/11/22.
//

import SwiftUI
import Firebase
import UserNotifications



struct SettingsView: View {
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var firestoreViewModel : FirestoreViewModel
    @StateObject var settingViewModel = SettingsViewModel()
    
    @State var showAlert: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack {
                ProfileImageView(
                    path: firestoreViewModel.firestoreUser?.image,
                    systemName: "person.circle.fill",
                    size: 90,
                    color: .gray)
                .padding(.vertical,5)
                
                Text("\( firestoreViewModel.firestoreUser?.username ?? "User")")
                    .font(.title)
                
                Text("\( firestoreViewModel.firestoreUser?.email ?? "")")
                    .font(.title3)
                    .accentColor(.gray)
                
                List {
                    Section() {
                        NavigationLink {
                            ModifyProfileView(firestoreViewModel: firestoreViewModel, settingViewModel: settingViewModel)
                        } label: {
                            Image(systemName: "person")
                            Text("Modify profile")
                        }
                        
                        NavigationLink {
                            ProvidersDetailView(authenticationViewModel: authenticationViewModel)
                        } label: {
                            Image(systemName: "person.crop.circle.badge.plus")
                            Text("Providers")
                        }
                        
                        NavigationLink {
                            NotificationDetailView(settingViewModel: settingViewModel)
                        } label: {
                            Image(systemName: "bell")
                            Text("Notifications")
                        }
                    }
                    
                    Button{
                        showAlert.toggle()
                    } label: {
                        
                        Text("Delete Account")
                    }.foregroundColor(.red)
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
                                            
                                            firestoreViewModel.deleteUserData(uid: uid){result in
                                                switch result {
                                                case .success:
                                                    authenticationViewModel.deleteUser()
                                                case .failure:
                                                    print("error deleting user")
                                                }
                                                
                                            }
                                            
                                        }
                                )
                            )
                        }
                    
                    Button("Logout") {
                        authenticationViewModel.logout()
                        firestoreViewModel.firestoreUser = nil
                    }
                    
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(authenticationViewModel: AuthenticationViewModel(),firestoreViewModel : FirestoreViewModel())
    }
}


