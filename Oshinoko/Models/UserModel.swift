//
//  UserModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import Foundation
import FirebaseFirestore
// ユーザー情報のモデル
struct User: Codable, Identifiable {
    @DocumentID var id: String? // Firestore ドキュメントの ID
    var name: String
    var email: String
    var iconURL: String
}
