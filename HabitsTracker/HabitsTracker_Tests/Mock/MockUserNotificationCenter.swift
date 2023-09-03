//
//  MockUserNotificationCenter.swift
//  HabitsTracker_Tests
//
//  Created by Manuela Merlo on 26/08/23.
//

@testable import HabitsTracker
import Foundation
import UserNotifications


class MockUserNotificationCenter: UserNotificationCenterProtocol {

    var addedRequests: [UNNotificationRequest] = []
    var notificationSettings: UNNotificationSettings?
    var identifiers: [String] = []
    
    init(notificationSettings: UNNotificationSettings? = nil) {
           self.notificationSettings = notificationSettings
    }


    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        addedRequests.append(request)
        completionHandler?(nil) // Simulate success
    }
    
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
        if let settings = notificationSettings {
            completionHandler(settings)
        }
    }
    
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        for identifier in identifiers {
            self.identifiers.removeAll { $0 == identifier }
        }
    }
    
    func removeAllPendingNotificationRequests() {
        identifiers = []
    }
}
