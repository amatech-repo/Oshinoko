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

    func isValid() -> Bool {
        return (-90...90).contains(latitude) && (-180...180).contains(longitude)
    }
}

struct Metadata: Codable {
    var createdBy: String
    var createdAt: Date
    var description: String
    var title: String
    var tags: [String]

    init(
        createdBy: String,
        createdAt: Date = Date(),
        description: String = "",
        title: String = "",
        tags: [String] = []
    ) {
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.description = description
        self.title = title
        self.tags = tags
    }
}

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let message: String
    let senderID: String
    let timestamp: Date
    let imageURL: String?
    let isImage: Bool
}
