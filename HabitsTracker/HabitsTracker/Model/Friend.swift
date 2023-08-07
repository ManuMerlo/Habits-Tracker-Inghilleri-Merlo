//
//  File.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 07/08/23.
//

import Foundation

struct Friend: Identifiable, Codable, Hashable {
    
    var id: String?
    var status: String?   // Waiting, Confirmed, Request
    
    mutating func modifyStatus(newStatus: String) {
        self.status = newStatus
        
    }
}


