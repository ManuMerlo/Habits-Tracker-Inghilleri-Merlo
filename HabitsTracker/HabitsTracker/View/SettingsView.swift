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
    
    @State var expandVerificationWithEmailFrom : Bool = false
    @State var textFieldEmail: String = ""
    @State var textFieldPassword: String = ""
    @State var showAlert: Bool = false
    
    
    @State private var showSheet = false
    
    var body: some View {
        NavigationStack{
            VStack {
                
                Button{
                    showSheet.toggle()
                }label:{
                    VStack {
                        if let image = settingViewModel.image{
                            Image(uiImage: image )
                                .resizable()
                                .frame(width: 90, height: 90)
                                .mask(Circle())
                            
                        } else{
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 90, height: 90)
                                .mask(Circle())
                                .foregroundColor(.gray)
                            
                        }
                        
                        Text("Change photo")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                    
                }.padding(3)
                
                Text("Manuela Merlo").font(.title)
                
                Text("merlomanu1999@gmail.com")
                    .font(.title3)
                    .accentColor(.gray)
                
                List {
                    Section() {
                        NavigationLink {
                            ProvidersDetailView()
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
                                            guard let uid = authenticationViewModel.user?.id else{
                                                print("Null uid before deleting a user")
                                                return
                                            }
                                            firestoreViewModel.deleteUserData(uid: uid){result in
                                                switch result {
                                                case .success:
                                                    authenticationViewModel.deleteUser()
                                                case .failure:
                                                    print("error deleting user ")
                                                }
                                                
                                            }
                                            
                                        }
                                )
                            )
                        }
                    
                    Button("Logout") {
                        authenticationViewModel.logout()
                    }
                    
                }
            }
        }.fullScreenCover(isPresented: $showSheet, onDismiss: {
            settingViewModel.persistimageToStorage()
        }) {
            SettingsViewModel.ImagePicker(selectedImage: $settingViewModel.image)
        }
    }
    
    @ViewBuilder
    func ProvidersDetailView() -> some View {
        List{
            HStack{
                Button(action:{
                    withAnimation{
                        self.expandVerificationWithEmailFrom.toggle()
                    }
                },label: {
                    HStack{
                        //Image(systemName: "envelope.fill")
                        Text("Connect with Email")
                        Spacer()
                        Image(systemName: self.expandVerificationWithEmailFrom ? "chevron.down": "chevron.up")
                    }
                })
                .disabled(authenticationViewModel.isEmailandPasswordLinked())
            }
            
            if expandVerificationWithEmailFrom {
                Group{
                    TextField("Insert email", text:$textFieldEmail)
                    SecureField("Insert password", text:$textFieldPassword)
                    Button("Accept"){
                        authenticationViewModel.linkEmailAndPassword(email: textFieldEmail, password: textFieldPassword)
                    }
                    .padding(5)
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    
                    if let messageError = authenticationViewModel.messageError {
                        Text(messageError)
                            .font(.body)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
            
            Button{
                authenticationViewModel.linkFacebook()
            } label: {
                Text("Connect with Facebook")
            }.disabled(authenticationViewModel.isFacebookLinked())
            
            Button{
                authenticationViewModel.linkGoogle()
            } label: {
                Text("Connect with Google")
            }.disabled(authenticationViewModel.isGoogleLinked())
            
        }.task {
            authenticationViewModel.getCurrentProvider()
        }
        .alert(authenticationViewModel.isAccountLinked ? "Link successful" : "Error", isPresented: $authenticationViewModel.showAlert) {
            Button("Accept"){
                print("Dismiss alert")
                if authenticationViewModel.isAccountLinked{
                    expandVerificationWithEmailFrom = false
                }
            }
        } message: {
            Text(authenticationViewModel.isAccountLinked ? "Success" : "Error")
        }
    }
    
    
}

struct NotificationDetailView: View {
    @ObservedObject var settingViewModel : SettingsViewModel
    
    var body: some View {
        Form {
            Section {
                
                Toggle(isOn: $settingViewModel.agreedToTerms, label: {
                    Text("Allow Notification")
                })
                .onChange(of: settingViewModel.agreedToTerms, perform: { newValue in
                    if !newValue {
                        if settingViewModel.dailyNotification {
                            settingViewModel.dailyNotification.toggle()
                        }
                        if settingViewModel.weeklyNotification {
                            settingViewModel.weeklyNotification.toggle()
                        }
                    }else{
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]){ success, error in
                            if success {
                                print("success")
                            }
                            else if let error = error {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    
                })
            }
            
            Section {
                
                Toggle(isOn: $settingViewModel.dailyNotification, label: {
                    Text("Daily Notification")
                })
                .onChange(of: settingViewModel.dailyNotification, perform: { newValue in
                    print("success daily")
                    if(newValue){
                        settingViewModel.dailyNotificationIdentifier = settingViewModel.scheduleNotifications(title: "Daily Notification", subtitle: "you are doing great", timeInterval: 86400, repeats: true)
                    }else{
                        print("Stop Notification")
                        settingViewModel.dailyNotificationIdentifier = settingViewModel.stopNotifications(identifier: settingViewModel.dailyNotificationIdentifier)
                    }
                }) .disabled(!settingViewModel.agreedToTerms)
                
                Toggle(isOn:  $settingViewModel.weeklyNotification, label: {
                    Text("Weakly Notifications")
                })
                .onChange(of: settingViewModel.weeklyNotification, perform: { newValue in
                    if(newValue){
                        settingViewModel.weeklyNotificationIdentifier = settingViewModel.scheduleNotifications(title: "Daily Notification", subtitle: "you are doing great", timeInterval: 86400*7, repeats: true)
                    }
                    else{
                        settingViewModel.weeklyNotificationIdentifier = settingViewModel.stopNotifications(identifier: settingViewModel.weeklyNotificationIdentifier)
                    }
                })
                .disabled(!settingViewModel.agreedToTerms)
                
            }
            
        }
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(authenticationViewModel: AuthenticationViewModel(),firestoreViewModel : FirestoreViewModel())
    }
}
