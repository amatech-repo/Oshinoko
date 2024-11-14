//
//  ChatModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import Foundation
import FirebaseFirestore

struct Pin: Codable, Identifiable {
    @DocumentID var id: String?
    var coordinate: Coordinate
    var metadata: Metadata
}

struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double
}

struct Metadata: Codable {
    var createdBy: String
    var createdAt: Date
    var description: String
    var title: String
    var tags: [String]
}

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    var message: String
    var senderID: String
    var timestamp: Date
    var imageURL: String?
    var isImage: Bool
}
