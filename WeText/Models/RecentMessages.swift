//
//  RecentMessages.swift
//  WeText
//
//  Created by Santhosh Srinivas on 15/12/21.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentMessage: Codable, Identifiable {
    
    @DocumentID var id: String?
    let text, email: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Date
    let uName: String
    let active: String
    
    
//    var username: String {
//        email.components(separatedBy: "@").first ?? email
//    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
