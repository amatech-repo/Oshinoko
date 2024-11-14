//
//  UserViewModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

import Foundation
import FirebaseFirestore
import FirebaseStorage

@MainActor
class UsersViewModel: ObservableObject {
    @Published var currentUser: User? // 現在のログインユーザー
    @Published var users: [User] = [] // すべてのユーザー

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // ユーザーを取得
    func fetchUsers() async {
        do {
            let snapshot = try await db.collection("users").getDocuments()
            self.users = snapshot.documents.compactMap { try? $0.data(as: User.self) }
        } catch {
            print("ユーザーの取得エラー: \(error.localizedDescription)")
        }
    }

    // ユーザーを Firestore に保存
    func saveUser(_ user: User) async {
        guard let userID = user.id else { return }
        do {
            try db.collection("users").document(userID).setData(from: user)
        } catch {
            print("ユーザーの保存エラー: \(error.localizedDescription)")
        }
    }

    // アイコン画像をアップロード
    func uploadIcon(image: UIImage, for userID: String) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("画像データの変換に失敗")
            return nil
        }

        let iconRef = storage.reference().child("user_icons/\(userID).jpg")

        do {
            let _ = try await iconRef.putDataAsync(imageData)
            let url = try await iconRef.downloadURL()
            return url.absoluteString
        } catch {
            print("アイコン画像のアップロードエラー: \(error.localizedDescription)")
            return nil
        }
    }

    // ユーザー情報を更新（アイコン込み）
    func updateUserIcon(image: UIImage, for userID: String) async {
        if let url = await uploadIcon(image: image, for: userID) {
            do {
                try await db.collection("users").document(userID).updateData(["iconURL": url])
                print("アイコンURLを更新しました: \(url)")
            } catch {
                print("アイコンURLの更新エラー: \(error.localizedDescription)")
            }
        }
    }
}
