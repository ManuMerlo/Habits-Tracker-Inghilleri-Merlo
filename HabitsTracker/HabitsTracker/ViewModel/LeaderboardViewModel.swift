//
//  LeaderboardViewModel.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 16/08/23.
//

import Foundation

//
//  SettingsViewModel.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 02/08/23.
//

import Foundation
import UserNotifications
import SwiftUI


final class LeaderBoardViewModel: ObservableObject {
    let today = ( Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    
    func sendPositionChangeNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "Ranking Position Change"
        content.subtitle = "You are losing positions in the rankings! Hurry up!!"
        content.sound = .default
        

        let trigger = UNTimeIntervalNotificationTrigger (timeInterval: 20, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        print("sending notification ranking")
        
        UNUserNotificationCenter.current().add(request)
        
    }
    
    func sortUsers(users:[User], timeFrame: TimeFrame) -> [User] {
        return users.sorted { user1, user2 in
            switch timeFrame {
            case .daily:
                return user1.dailyScores[today] > user2.dailyScores[today]
            case .weekly:
                return user1.dailyScores[7] > user2.dailyScores[7]
            }
        }
    }
     
}




