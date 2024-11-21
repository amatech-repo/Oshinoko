//
//  UserViewModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

@MainActor
class UsersViewModel: ObservableObject {
    @Published var currentUser: User? // 現在のログインユーザー
    @Published var users: [User] = [] // すべてのユーザー
    @Published var selectedImage: UIImage? // ユーザーが選択した画像

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // MARK: - Public Methods

    /// Firestoreから全ユーザーを取得
    func fetchUsers() async {
        do {
            users = try await db.collection("users")
                .getDocuments()
                .documents
                .compactMap { try? $0.data(as: User.self) }
        } catch {
            print("ユーザーの取得エラー: \(error.localizedDescription)")
        }
    }

    /// Firestoreにユーザーを保存
    func saveUser(_ user: User) async {
        guard let userID = user.id else { return }
        do {
            try db.collection("users").document(userID).setData(from: user)
        } catch {
            print("ユーザーの保存エラー: \(error.localizedDescription)")
        }
    }

    /// アイコンを更新
    func updateUserIcon(for userID: String) async {
        if let iconURL = await uploadImage(to: "user_icons/\(userID).jpg") {
            do {
                try await db.collection("users").document(userID).updateData(["iconURL": iconURL])
                print("アイコンURLを更新しました: \(iconURL)")
            } catch {
                print("アイコンURLの更新エラー: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Private Helpers

    /// 画像をFirebase Storageにアップロード
    private func uploadImage(to path: String) async -> String? {
        guard let selectedImage = selectedImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            print("画像データの変換に失敗")
            return nil
        }

        let ref = storage.reference().child(path)

        do {
            let _ = try await ref.putDataAsync(imageData)
            return try await ref.downloadURL().absoluteString
        } catch {
            print("画像のアップロードエラー: \(error.localizedDescription)")
            return nil
        }
    }
}
