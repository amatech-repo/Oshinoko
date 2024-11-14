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
    private var listener: ListenerRegistration?

    init(pinID: String) {
        self.pinID = pinID
    }

    func startListeningForMessages(pinID: String) {
        guard !pinID.isEmpty else {
            print("Error: Pin ID is empty")
            return
        }

        listener = db.collection("pins")
            .document(pinID)
            .collection("chats")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Failed to listen for messages: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self.messages = documents.compactMap { try? $0.data(as: ChatMessage.self) }
            }
    }

    func stopListeningForMessages() {
        listener?.remove()
        listener = nil
    }

    deinit {
        listener?.remove()
    }

    func uploadImage(image: UIImage, senderID: String) async {
        guard let resizedImage = image.resized(toWidth: 1024),
              let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
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

            try await db.collection("pins").document(pinID).collection("chats").addDocument(from: newMessage)
            selectedImage = nil
        } catch {
            errorMessage = AlertMessage(message: "画像アップロードエラー: \(error.localizedDescription)")
        }
    }

    func sendMessage(senderID: String) async {
        guard !pinID.isEmpty else {
            errorMessage = AlertMessage(message: "ピンIDが無効です")
            return
        }
        guard !messageText.isEmpty else { return }

        let newMessage = ChatMessage(
            id: nil, // 手動で設定しない
            message: messageText,
            senderID: senderID,
            timestamp: Date(),
            imageURL: nil,
            isImage: false
        )

        do {
            try await db.collection("pins").document(pinID).collection("chats").addDocument(from: newMessage)
            messageText = "" // 入力フィールドをクリア
        } catch {
            errorMessage = AlertMessage(message: "メッセージ送信エラー: \(error.localizedDescription)")
        }
    }
}

