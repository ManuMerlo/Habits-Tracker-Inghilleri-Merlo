import Foundation
import UserNotifications
import SwiftUI

/// A view model responsible for managing leaderboards and notifications related to user ranking.
final class LeaderBoardViewModel: ObservableObject {
    
    /// A computed property representing the index for today in the week (0 is Monday, 6 is Sunday).
    let today = ( Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    
    @State var notificationCenter: UserNotificationCenterProtocol
    
    /// Initializes a new instance of `LeaderBoardViewModel`.
    ///
    /// - Parameter notificationCenter: The notification center to use. Defaults to the system's current user notification center.
    init(notificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current()) {
        self.notificationCenter = notificationCenter
    }
    
    /// Initializes a new instance of `LeaderBoardViewModel` for testing purposes.
    ///
    /// - Parameter notificationCenter: The optional notification center to use.
    init(notificationCenter: UserNotificationCenterProtocol? = nil) {
        if let providedNotificationCenter = notificationCenter {
            self.notificationCenter = providedNotificationCenter
        } else {
            self.notificationCenter = UNUserNotificationCenter.current()
        }
    }
    
    /// Sends a notification to the user about their position change in the leaderboard.
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
    
    /// Sorts the provided users based on their scores for the given time frame.
    ///
    /// - Parameters:
    ///   - users: The array of `User` instances to sort.
    ///   - timeFrame: The `TimeFrame` enum value representing the desired time frame (daily or weekly) for the sort.
    ///
    /// - Returns: An array of sorted `User` instances based on their scores for the given time frame.
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




