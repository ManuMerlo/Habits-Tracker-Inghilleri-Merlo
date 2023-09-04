import Foundation
import UserNotifications
import SwiftUI

/// A view model responsible for managing leaderboards and notifications related to user ranking.
final class LeaderBoardViewModel: ObservableObject {
    
    /// A computed property representing the index for today in the week (0 is Monday, 6 is Sunday).
    let today = (Calendar.current.component(.weekday, from: Date()) + 5 ) % 7
    
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




