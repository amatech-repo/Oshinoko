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

struct AlertMessage: Identifiable {
    let id = UUID() // 一意の識別子
    let message: String
}

@MainActor
class ChatViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: AlertMessage?
    @Published var messageText: String = "" // メッセージ入力用


    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    private let pinID: String

    init(pinID: String) {
        self.pinID = pinID
    }

    // 非同期で画像をアップロード
    func uploadImage(image: UIImage, senderID: String) async {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = AlertMessage(message: "画像データの変換に失敗しました")
            return
        }

        let imageID = UUID().uuidString
        let storageRef = storage.reference().child("chat_images/\(imageID).jpg")

        do {
            let _ = try await storageRef.putDataAsync(imageData)
            let downloadURL = try await storageRef.downloadURL()

            let newMessage = ChatMessage(
                id: nil,
                message: "画像が送信されました",
                senderID: senderID,
                timestamp: Date(),
                imageURL: downloadURL.absoluteString,
                isImage: true
            )
            
            try db.collection("pins").document(pinID).collection("chats").addDocument(from: newMessage)
            selectedImage = nil // 選択画像のリセット
        } catch {
            errorMessage = AlertMessage(message: "画像アップロードエラー: \(error.localizedDescription)")
        }
    }

    // Firestore からメッセージを取得
    func fetchMessages() async {
        do {
            let snapshot = try await db.collection("pins").document(pinID).collection("chats")
                .order(by: "timestamp")
                .getDocuments()
            messages = snapshot.documents.compactMap { try? $0.data(as: ChatMessage.self) }
        } catch {
            errorMessage = AlertMessage(message: "メッセージ取得エラー: \(error.localizedDescription)")
        }
    }

    func sendMessage(senderID: String) async {
        guard !messageText.isEmpty else { return }

        isLoading = true
        defer { isLoading = false }

        let newMessage = ChatMessage(
            id: nil,
            message: messageText,
            senderID: senderID,
            timestamp: Date(),
            imageURL: nil,
            isImage: false
        )

        do {
            try await db.collection("pins").document(pinID).collection("chats").addDocument(from: newMessage)
            messages.append(newMessage)
            messageText = "" // 入力フィールドをクリア
        } catch {
            errorMessage = AlertMessage(message: "メッセージ送信に失敗しました: \(error.localizedDescription)")
        }
    }

}
