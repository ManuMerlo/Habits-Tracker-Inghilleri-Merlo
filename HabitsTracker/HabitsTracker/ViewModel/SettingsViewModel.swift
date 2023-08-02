//
//  SettingsViewModel.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 02/08/23.
//

import Foundation
import UserNotifications
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var agreedToTerms = true
    @Published var dailyNotification = false
    @Published var weeklyNotification = false
    @Published var dailyNotificationIdentifier: String?
    @Published var weeklyNotificationIdentifier:  String?
    
    
    func scheduleNotifications( title: String, subtitle: String,timeInterval: TimeInterval, repeats: Bool)-> String?{
        let identifier : String
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = .default
        
        identifier = UUID().uuidString
        
        let trigger = UNTimeIntervalNotificationTrigger (timeInterval: timeInterval, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
       
        UNUserNotificationCenter.current().add(request)
    
        return identifier
    }
    
    func stopNotifications(identifier : String?) -> String? {
        if let id = identifier {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            return nil // Clear the stored identifier
        }
        return identifier
    }
    
}
