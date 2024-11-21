//
//  ChatViewModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var messageText: String = ""

    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    let pinID: String
    private var listener: ListenerRegistration?

    init(pinID: String) {
        self.pinID = pinID
    }

    // MARK: - Public Methods

    /// Firestoreからメッセージをリスニング
    func startListeningForMessages() {
        guard !pinID.isEmpty else {
            errorMessage = "ピンIDが無効です"
            return
        }

        isLoading = true
        listener = db.collection("pins")
            .document(pinID)
            .collection("chats")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snapshot, error in
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Failed to fetch messages: \(error.localizedDescription)"
                    return
                }
                self?.messages = snapshot?.documents.compactMap { try? $0.data(as: ChatMessage.self) } ?? []
            }
    }

    /// Firestoreのリスニングを停止
    func stopListeningForMessages() {
        listener?.remove()
        listener = nil
    }

    /// メッセージを送信
    func sendMessage(senderID: String) async {
        guard !messageText.isEmpty else { return }

        let newMessage = ChatMessage(
            id: nil,
            message: messageText,
            senderID: senderID,
            timestamp: Date(),
            imageURL: nil,
            isImage: false,
            senderIconURL: AuthViewModel.shared.icon
        )

        do {
            try await db.collection("pins").document(pinID).collection("chats").addDocument(from: newMessage)
            messageText = ""
        } catch {
            errorMessage = "メッセージ送信エラー: \(error.localizedDescription)"
        }
    }

    /// 画像をアップロードして送信
    func uploadImage(image: UIImage, senderID: String) async {
        guard let imageURL = await uploadImageToStorage(image: image) else {
            errorMessage = "画像アップロードエラー"
            return
        }

        let newMessage = ChatMessage(
            id: nil,
            message: "画像が送信されました",
            senderID: senderID,
            timestamp: Date(),
            imageURL: imageURL,
            isImage: true,
            senderIconURL: AuthViewModel.shared.icon
        )

        do {
            try await db.collection("pins").document(pinID).collection("chats").addDocument(from: newMessage)
            selectedImage = nil
        } catch {
            errorMessage = "画像メッセージ送信エラー: \(error.localizedDescription)"
        }
    }

    // MARK: - Private Helpers

    /// 画像をFirebase Storageにアップロード
    private func uploadImageToStorage(image: UIImage) async -> String? {
        guard let imageData = image.resized(toWidth: 1024)?.jpegData(compressionQuality: 0.8) else { return nil }
        let imageID = UUID().uuidString
        let ref = storage.reference().child("chat_images/\(imageID).jpg")

        do {
            let _ = try await ref.putDataAsync(imageData)
            return try await ref.downloadURL().absoluteString
        } catch {
            return nil
        }
    }

    deinit {
        listener?.remove()
    }
}
