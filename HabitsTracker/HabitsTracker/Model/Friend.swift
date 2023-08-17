import Foundation

struct Friend: Identifiable, Codable, Hashable {
    
    var id: String
    var status: String   // Waiting, Confirmed, Request
    
    mutating func modifyStatus(newStatus: String) {
        self.status = newStatus
        
    }
}


