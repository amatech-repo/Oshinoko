//
//  AuthViewModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    static let shared = AuthViewModel() // シングルトンインスタンス

    @Published var email: String = "test@mail.com"
    @Published var password: String = "test12345"
    @Published var errorMessage: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var selectedImage: UIImage? // ユーザーが選択した画像
    @Published var userID: String?
    @Published var icon: String?
    @Published var name: String = ""

    private let auth = Auth.auth()
    private let storage = Storage.storage()
    private let db = Firestore.firestore()

    // MARK: - Public Methods

    /// ログイン
    func logIn() async {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            print("Logged in user: \(result.user.uid)")
            isAuthenticated = true
            userID = result.user.uid

            // Firestoreからユーザー情報を取得
            if let userData = try await fetchUserData(for: result.user.uid) {
                name = userData["name"] as? String ?? "Unknown User"
                icon = userData["iconURL"] as? String
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// 新規登録
    func signUp() async {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let userID = result.user.uid

            // アイコン画像をアップロード
            let imageURL = await uploadProfileImage(for: userID)

            // Firestoreにユーザー情報を保存
            try await saveUserData(userID: userID, imageURL: imageURL)
            isAuthenticated = true
            self.userID = userID
            self.icon = imageURL
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private Helpers

    /// Firestoreにユーザー情報を保存
    private func saveUserData(userID: String, imageURL: String?) async throws {
        let userData: [String: Any] = [
            "id": userID,
            "email": email,
            "name": name,
            "iconURL": imageURL ?? "" // デフォルトURL
        ]
        try await db.collection("users").document(userID).setData(userData)
    }

    /// Firestoreからユーザー情報を取得
    private func fetchUserData(for userID: String) async throws -> [String: Any]? {
        let userDocument = try await db.collection("users").document(userID).getDocument()
        return userDocument.data()
    }

    /// プロフィール画像をアップロード
    private func uploadProfileImage(for userID: String) async -> String? {
        guard let selectedImage = selectedImage else { return nil }
        return await uploadImage(to: "user_icons/\(userID).jpg")
    }

    /// 画像をFirebase Storageにアップロード
    private func uploadImage(to path: String) async -> String? {
        guard let selectedImage = selectedImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
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
