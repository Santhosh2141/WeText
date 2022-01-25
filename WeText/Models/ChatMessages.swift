//
//  ChatMessages.swift
//  WeText
//
//  Created by Santhosh Srinivas on 15/12/21.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
//    var timeAgo: String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .abbreviated
//        return formatter.localizedString(for: timestamp, relativeTo: Date())
//    }
    
}
