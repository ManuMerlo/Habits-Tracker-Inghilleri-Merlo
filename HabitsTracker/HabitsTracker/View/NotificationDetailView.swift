//
//  NotificationDetailView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 06/08/23.
//

import SwiftUI

struct NotificationDetailView: View {
    
    @ObservedObject var settingViewModel : SettingsViewModel
    
    var width: CGFloat
    
    var body: some View {
        VStack{
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
                .foregroundColor(.white.opacity(0.7))
                .listRowBackground(Color("oxfordBlue"))
                .listRowSeparatorTint(.white.opacity(0.7))
                
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
                .foregroundColor(.white.opacity(0.7))
                .listRowBackground(Color("oxfordBlue"))
                .listRowSeparatorTint(.white.opacity(0.7))
                
            }
            .frame(width: width)
            .scrollContentBackground(.hidden)
            
        }.frame(maxWidth: .infinity)
        
            .background(RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500).opacity(0.98))
    }
}

struct NotificationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationDetailView(settingViewModel: SettingsViewModel(),width: 600)
    }
}
