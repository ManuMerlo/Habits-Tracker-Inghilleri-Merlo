import SwiftUI

struct NotificationDetailView: View {
    
    @ObservedObject var settingsViewModel : SettingsViewModel
    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State var width = UIScreen.main.bounds.width
    
    var body: some View {
        VStack{
            Form {
                Section {
                    Toggle(isOn: $settingsViewModel.agreedToTerms, label: {
                        Text("Allow Notification")
                    })
                    .onChange(of: settingsViewModel.agreedToTerms, perform: { newValue in
                        if !newValue {
                            if settingsViewModel.dailyNotification {
                                settingsViewModel.dailyNotification.toggle()
                            }
                            if settingsViewModel.weeklyNotification {
                                settingsViewModel.weeklyNotification.toggle()
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
                .foregroundColor(.white.opacity(0.7))
                .listRowBackground(Color("oxfordBlue"))
                .listRowSeparatorTint(.white.opacity(0.7))
                
                Section {
                    
                    Toggle(isOn: $settingsViewModel.dailyNotification, label: {
                        Text("Daily Notification")
                    })
                    .onChange(of: settingsViewModel.dailyNotification, perform: { newValue in
                        print("success daily")
                        if(newValue){
                            settingsViewModel.dailyNotificationIdentifier = settingsViewModel.scheduleNotifications(title: "Daily Notification", subtitle: "you are doing great", timeInterval: 86400, repeats: true)
                        }else{
                            print("Stop Notification")
                            settingsViewModel.dailyNotificationIdentifier = settingsViewModel.stopNotifications(identifier: settingsViewModel.dailyNotificationIdentifier)
                        }
                    }) .disabled(!settingsViewModel.agreedToTerms)
                    
                    Toggle(isOn:  $settingsViewModel.weeklyNotification, label: {
                        Text("Weakly Notifications")
                    })
                    .onChange(of: settingsViewModel.weeklyNotification, perform: { newValue in
                        if(newValue){
                            settingsViewModel.weeklyNotificationIdentifier = settingsViewModel.scheduleNotifications(title: "Daily Notification", subtitle: "you are doing great", timeInterval: 86400*7, repeats: true)
                        }
                        else{
                            settingsViewModel.weeklyNotificationIdentifier = settingsViewModel.stopNotifications(identifier: settingsViewModel.weeklyNotificationIdentifier)
                        }
                    })
                    .disabled(!settingsViewModel.agreedToTerms)
                    
                }
                .foregroundColor(.white.opacity(0.7))
                .listRowBackground(Color("oxfordBlue"))
                .listRowSeparatorTint(.white.opacity(0.7))
                
            }
            .frame(width: isLandscape ? width/1.3 : width)
            .scrollContentBackground(.hidden)
            
        }.frame(maxWidth: .infinity)
            .accessibilityIdentifier("NotificationVStack")
        .background(RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500))
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

struct NotificationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationDetailView(settingsViewModel:SettingsViewModel()) .environmentObject(OrientationInfo())
    }
}
