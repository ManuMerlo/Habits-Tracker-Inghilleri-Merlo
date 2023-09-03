import Foundation
import UserNotifications
import SwiftUI


final class LeaderBoardViewModel: ObservableObject {
    let today = ( Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    
    @State var notificationCenter: UserNotificationCenterProtocol

    // Default constructor
    init(notificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current()) {
        self.notificationCenter = notificationCenter
    }

    // Testing purposes
    init(notificationCenter: UserNotificationCenterProtocol? = nil) {
        if let providedNotificationCenter = notificationCenter {
            self.notificationCenter = providedNotificationCenter
        } else {
            self.notificationCenter = UNUserNotificationCenter.current()
        }
    }
    
    func sendPositionChangeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Ranking Position Change"
        content.subtitle = "You are losing positions in the rankings! Hurry up!!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger (timeInterval: 20, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        print("sending notification ranking")
        
        notificationCenter.add(request){ _ in
        }
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




