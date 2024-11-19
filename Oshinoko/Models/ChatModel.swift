//
//  ChatModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import Foundation
import FirebaseFirestore

struct Pin: Codable, Identifiable, Equatable {
    @DocumentID var id: String? // Firestoreが自動設定
    var coordinate: Coordinate
    var metadata: Metadata

    // Equatable 準拠のための比較
    static func == (lhs: Pin, rhs: Pin) -> Bool {
        lhs.id == rhs.id
    }

    // もし`id`がnilの場合、他の識別子を返す（`ForEach`対応）
    var wrappedID: String {
        id ?? UUID().uuidString
    }

    let iconURL: String? // アイコン画像のURLを追加
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
    let senderIconURL: String?

    // id が nil の場合、他の識別子を提供
    var wrappedID: String {
        id ?? UUID().uuidString
    }
}
