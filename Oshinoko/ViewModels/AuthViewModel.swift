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

    @Published var email: String = "test@mail.com3"
    @Published var password: String = "test1234"
    @Published var errorMessage: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var selectedImage: UIImage? // ユーザーが選択した画像
    @Published var userID: String? = nil
    @Published var icon: String? = nil
    @Published var name: String = ""

    private let auth = Auth.auth()
    private let storage = Storage.storage()
    private let db = Firestore.firestore()

    func logIn() async {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            print("Logged in user: \(result.user.uid)")
            isAuthenticated = true
            userID = result.user.uid

            // ユーザー情報を取得
            let userDocument = try await db.collection("users").document(result.user.uid).getDocument()
            if let data = userDocument.data() {
                name = data["name"] as? String ?? "Unknown User"
                icon = data["iconURL"] as? String
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // 新規登録
    func signUp() async {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let userID = result.user.uid

            // 画像をアップロード
            guard let imageURL = await uploadProfileImage(for: userID) else {
                errorMessage = "画像のアップロードに失敗しました"
                return
            }

            // Firestoreにユーザー情報を保存
            let userData: [String: Any] = [
                "id": userID,
                "email": email,
                "name": name,
                "iconURL": imageURL
            ]

            try await db.collection("users").document(userID).setData(userData)
            isAuthenticated = true
            self.userID = userID
            self.icon = imageURL
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // 画像をFirebase Storageにアップロード
    private func uploadProfileImage(for userID: String) async -> String? {
        guard let selectedImage = selectedImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            return nil
        }

        let storageRef = storage.reference().child("user_icons/\(userID).jpg")

        do {
            let _ = try await storageRef.putDataAsync(imageData)
            let downloadURL = try await storageRef.downloadURL()
            return downloadURL.absoluteString
        } catch {
            print("画像のアップロードエラー: \(error.localizedDescription)")
            return nil
        }
    }
}
