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
    
    @State var modify: Bool = false
    @State var isListEnabled: Bool = true
    @State var showAlert: Bool = false
    @State var showSheet: Bool = false
    @State var showDatePicker : Bool = false
    @State var showHeightPicker : Bool = false
    @State var showWeightPicker : Bool = false
    @State var showSexPicker : Bool = false
    
    @State var selectedDate: Date = Date()
    @State var selectedHeight : Int = 150
    @State var selectedWeight : Int = 60
    @State var selectedSex : Sex = Sex.Unspecified
        
    var body: some View {
        NavigationStack{
            VStack {
                
                VStack {
                    
                    if let path =  firestoreViewModel.firestoreUser?.image {
                        AsyncImage(url: URL(string: path)){ phase in
                            switch phase {
                                case .failure:
                                Image(systemName: "person.circle.fill")
                                    .font(.largeTitle) case
                                .success(let image):
                                    image .resizable()
                                default: ProgressView() }
                            
                        } .frame(width: 90, height: 90)
                          .mask(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 90, height: 90)
                            .mask(Circle())
                            .foregroundColor(.gray)
                    }
                    
                }
                .padding(.horizontal, 20)
                
                Text("\( firestoreViewModel.firestoreUser?.username ?? "User")")
                    .font(.title)
                
                Text("\( firestoreViewModel.firestoreUser?.email ?? "")")
                    .font(.title3)
                    .accentColor(.gray)
                
                List {
                    Section() {
                        NavigationLink {
                            modifiPorfileView()
                        } label: {
                            Image(systemName: "person")
                            Text("Modify profile")
                        }
                        
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
                                            guard let uid =  firestoreViewModel.firestoreUser?.id else{
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
        }
    }
    
    @ViewBuilder
    func modifiPorfileView() -> some View {
        VStack {
            VStack(spacing: 0) {
                
                Button{
                    showSheet.toggle()
                }label:{
                    VStack {
                        
                        if let path =  firestoreViewModel.firestoreUser?.image {
                            AsyncImage(url: URL(string: path)){ phase in
                                switch phase {
                                    case .failure:
                                    Image(systemName: "person.circle.fill")
                                        .font(.largeTitle) case
                                    .success(let image):
                                        image .resizable()
                                    default: ProgressView() }
                                
                            } .frame(width: 90, height: 90)
                              .mask(Circle())
                        } else {
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
                    
                }.padding(5)
                
                Text("Customise your profile")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Spacer() // Spazio vuoto sopra per spingere il contenuto in alto
                
                List {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text("\( firestoreViewModel.firestoreUser?.username ?? "User")")
                    }
                        
                    Button {
                        showDatePicker.toggle()
                        isListEnabled.toggle()
                    } label: {
                        HStack {
                            Text("Birthdate")
                            Spacer()
                            Text(settingViewModel.dateToString(selectedDate))
                        }
                    }.disabled(!modify)
                    .foregroundColor(!modify ? .gray: .black)
                    
                    Button {
                        showSexPicker.toggle()
                        isListEnabled.toggle()
                    } label: {
                        HStack {
                            Text("Sex")
                            Spacer()
                            Text("\((firestoreViewModel.firestoreUser?.sex ?? Sex.Unspecified).rawValue )")
                        }
                    }.disabled(!modify)
                        .foregroundColor(!modify ? .gray: .black)
                    
                    
                    Button {
                        showHeightPicker.toggle()
                        isListEnabled.toggle()
                    } label: {
                        HStack {
                            Text("Height")
                            Spacer()
                            Text("\( firestoreViewModel.firestoreUser?.height ?? 0 )")
                        }
                    }.disabled(!modify)
                        .foregroundColor(!modify ? .gray: .black)
                    
                    
                    Button {
                        showWeightPicker.toggle()
                        isListEnabled.toggle()
                    } label: {
                        HStack {
                            Text("Weight")
                            Spacer()
                            Text("\( firestoreViewModel.firestoreUser?.weight ?? 0 )")
                        }
                    }.disabled(!modify)
                        .foregroundColor(!modify ? .gray: .black)
                    
                }
                
            }.disabled(!isListEnabled)
            
            Spacer()
            
            if showDatePicker {
                VStack {
                    Button {
                        firestoreViewModel.firestoreUser!.setBirthDate(birthDate: settingViewModel.dateToString(selectedDate))
                        firestoreViewModel.modifyUser(
                            uid:  firestoreViewModel.firestoreUser!.id!,
                            field: "birthdate",
                            value: settingViewModel.dateToString(selectedDate),
                            type: "String")
                        
                        showDatePicker.toggle()
                        isListEnabled.toggle()
                    } label: {
                        Text("Done")
                    }
                    DatePicker(selection: $selectedDate, displayedComponents: .date) {}
                        .datePickerStyle(WheelDatePickerStyle())
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.8))
            }
            
            if(showSexPicker){
                VStack {
                    Button {
                        firestoreViewModel.firestoreUser!.setSex(sex:selectedSex)
                        firestoreViewModel.modifyUser(
                            uid:  firestoreViewModel.firestoreUser!.id!,
                            field: "sex",
                            value: selectedSex.rawValue,
                            type: "String")
                        
                        showSexPicker.toggle()
                        isListEnabled.toggle()
                    }label: {
                        Text("Done")
                    }
                    Picker(selection: $selectedSex, label: Text("Select your sex" )) {
                        ForEach(Sex.allCases, id: \.self) { item in
                            Text("\(item.rawValue)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                }
            }
            
            if (showHeightPicker) {
                SettingsViewModel.PickerView(
                    firestoreViewModel:firestoreViewModel,
                    user: $firestoreViewModel.firestoreUser,
                    property: "height",
                    selectedItem: $selectedHeight,
                    booleanValuePicker: $showHeightPicker,
                    booleanValueList: $isListEnabled,
                    rangeMin: 50,
                    rangeMax: 300,
                    unitaryMeasure: "cm")
            }
            
            if (showWeightPicker){
                SettingsViewModel.PickerView(
                    firestoreViewModel:firestoreViewModel,
                    user: $firestoreViewModel.firestoreUser,
                    property: "weight",
                    selectedItem: $selectedWeight,
                    booleanValuePicker: $showWeightPicker,
                    booleanValueList: $isListEnabled,
                    rangeMin: 30,
                    rangeMax: 180,
                    unitaryMeasure: "kg")
            }
            
        }
        .navigationBarBackButtonHidden(!isListEnabled || modify)
        .toolbar {
            Button {
                //if(modify){
                //    firestoreViewModel.addNewUser(user: authenticationViewModel.user!)
                //}
                modify.toggle()
            } label: {
                Text(modify ? "Done" : "Modify")
            }.disabled(!isListEnabled)
            
        }
        .fullScreenCover(isPresented: $showSheet, onDismiss: {
            settingViewModel.persistimageToStorage { result in
                switch result {
                case .success(let path):
                    firestoreViewModel.firestoreUser!.setImage(path: path)
                    firestoreViewModel.modifyUser(
                        uid:  firestoreViewModel.firestoreUser!.id!,
                        field: "image",
                        value: path,
                        type:"String")
                
                case .failure(let error):
                    print("\(error.localizedDescription)")
                    //TODO: handle message on screen
                }
            }
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


