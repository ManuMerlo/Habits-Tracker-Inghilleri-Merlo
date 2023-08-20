import Foundation

struct Friend: Codable, Hashable {
    
    let id: String
    var status: FriendStatus
    
    mutating func modifyStatus(newStatus: FriendStatus) {
        self.status = newStatus
    }
}

enum FriendStatus: String, Codable, CaseIterable {
    case Waiting = "Waiting"
    case Request = "Request"
    case Confirmed = "Confirmed"
}
