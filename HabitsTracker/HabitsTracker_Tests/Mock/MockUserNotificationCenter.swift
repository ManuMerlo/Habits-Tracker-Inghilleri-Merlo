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
    var addedRequest: UNNotificationRequest?
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?){
        self.addedRequest = request
        completionHandler?(nil)
    }
}
