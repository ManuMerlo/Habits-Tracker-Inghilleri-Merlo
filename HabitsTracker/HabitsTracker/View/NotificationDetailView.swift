import SwiftUI

struct NotificationDetailView: View {
    
    @ObservedObject var settingsViewModel : SettingsViewModel
    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State var width = UIScreen.main.bounds.width
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Toggle(isOn: $settingsViewModel.notificationPermissionGranted, label: {
                        Text("Allow Notification")
                    })
                    .onChange(of: settingsViewModel.notificationPermissionGranted) { newValue in
                        if !newValue {
                            settingsViewModel.dailyNotification = false
                            settingsViewModel.weeklyNotification = false
                        }
                        settingsViewModel.saveNotificationPermission(value: newValue)
                    }
                }
                .disabled(!settingsViewModel.settingsNotifications)
                .foregroundColor(.white.opacity(0.7))
                .listRowBackground(Color("oxfordBlue"))
                .listRowSeparatorTint(.white.opacity(0.7))
                
                Section {
                    Toggle(isOn: $settingsViewModel.dailyNotification, label: {
                        Text("Daily Notification")
                    })
                    .disabled(!settingsViewModel.notificationPermissionGranted)
                    .onChange(of: settingsViewModel.dailyNotification) { newValue in
                        if newValue {
                            settingsViewModel.startDailyNotifications()
                        } else {
                            settingsViewModel.stopDailyNotifications()
                        }
                    }
                    
                    Toggle(isOn: $settingsViewModel.weeklyNotification, label: {
                        Text("Weekly Notifications")
                    })
                    .disabled(!settingsViewModel.notificationPermissionGranted)
                    .onChange(of: settingsViewModel.weeklyNotification) { newValue in
                        if newValue {
                            settingsViewModel.startWeeklyNotifications()
                        } else {
                            settingsViewModel.stopWeeklyNotifications()
                        }
                    }
                }.foregroundColor(.white.opacity(0.7))
                .listRowBackground(Color("oxfordBlue"))
                .listRowSeparatorTint(.white.opacity(0.7))
                
                
                
            }.frame(width: isLandscape ? width/1.3 : width, height: 300)
                .scrollContentBackground(.hidden)
            
            if !settingsViewModel.settingsNotifications {
                VStack(){
                    Text("You have to allow notifications in your phone settings")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(10)
                }
                .padding(15)
                .background(.white.opacity(0.1))
                .cornerRadius(15)
                .frame(width: isLandscape ? width/1.3 : width)
            }
            Spacer()
        }
        .task {
            await settingsViewModel.checkNotificationPermissionGanted()
            if !settingsViewModel.settingsNotifications {
                do {
                    let result = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                    settingsViewModel.settingsNotifications = result
                } catch {
                    settingsViewModel.settingsNotifications = false
                }
            }
        }
        .refreshable {
            await settingsViewModel.checkNotificationPermissionGanted()
            if !settingsViewModel.settingsNotifications {
                do {
                    let result = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                    settingsViewModel.settingsNotifications = result
                } catch {
                    settingsViewModel.settingsNotifications = false
                }
            }
        }
        .frame(maxWidth: .infinity)
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
