//
//  ChatViewModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import Foundation
import FirebaseFirestore
import SwiftUI

import FirebaseStorage

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var messageText: String = ""
    @Published var selectedImage: UIImage? // 選択された画像

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let pinID: String

    init(pinID: String) {
        self.pinID = pinID
        Task {
            await fetchMessages()
        }
    }

    // 画像をアップロード
    func uploadImage(image: UIImage, senderID: String) async {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("画像データの変換に失敗")
            return
        }

        let imageID = UUID().uuidString // 一意のファイル名を生成
        let storageRef = storage.reference().child("chat_images/\(imageID).jpg")

        do {
            // 画像をアップロード
            let _ = try await storageRef.putDataAsync(imageData)
            // ダウンロードURLを取得
            let downloadURL = try await storageRef.downloadURL()

            // Firestore に画像メッセージを保存
            let newMessage = ChatMessage(
                id: nil,
                message: "画像を送信しました",
                senderID: senderID,
                timestamp: Date(),
                imageURL: downloadURL.absoluteString,
                isImage: true
            )
            try db.collection("pins").document(pinID).collection("chats").addDocument(from: newMessage)

            await fetchMessages() // メッセージ一覧を再取得
        } catch {
            print("画像のアップロードエラー: \(error.localizedDescription)")
        }
    }
}
