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



        // 初期化時にUserDefaultsからデータを読み取る
        init() {
            loadIconFromUserDefaults()
        }

    private func saveIconToUserDefaults(iconURL: String) {
        UserDefaults.standard.set(iconURL, forKey: "iconURL")
        print("⭐️ UserDefaultsに保存されたiconURL: \(iconURL)")
    }

        func loadIconFromUserDefaults() {
            if let savedIconURL = getIconFromUserDefaults() {
                self.icon = savedIconURL
                print("⭐️ UserDefaultsから読み込まれたiconURL: \(savedIconURL)")
            } else {
                print("⚠️ UserDefaultsにiconURLが保存されていません")
            }
        }

        private func getIconFromUserDefaults() -> String? {
            UserDefaults.standard.string(forKey: "iconURL")
        }



    // MARK: - Public Methods

    /// ログイン
    func logIn() async {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            print("Logged in user: \(result.user.uid)")
            isAuthenticated = true
            userID = result.user.uid

            // Firestoreからユーザー情報を取得
            if let fetchedData = try await fetchUserData(for: result.user.uid) { // 修正: userData を fetchedData に変更
                icon = fetchedData["iconURL"] as? String
                if let iconURL = icon {
                    saveIconToUserDefaults(iconURL: iconURL) // ローカル保存
                }
                print("⭐️loginユーザーのアイコンURL: \(icon ?? "なし")")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }






    /// 新規登録
    func signUp() async {
        do {
            // Firebase Authenticationでユーザー作成
            let result = try await auth.createUser(withEmail: email, password: password)
            let userID = result.user.uid
            self.userID = userID
            print("⭐️サインアップ成功: \(userID)")

            // プロフィール画像をアップロード
            let imageURL = await uploadProfileImage(for: userID)
            self.icon = imageURL // `icon` プロパティに設定

            if let imageURL = imageURL {
                // Firestoreにユーザー情報を保存
                try await saveUserData(userID: userID, imageURL: imageURL)
                saveIconToUserDefaults(iconURL: imageURL) // UserDefaultsに保存
                print("⭐️サインアップ完了、アイコンURL: \(imageURL)")
            } else {
                print("⚠️ プロフィール画像のアップロードに失敗")
            }

            isAuthenticated = true
        } catch {
            // エラーハンドリング
            errorMessage = error.localizedDescription
            print("サインアップエラー: \(errorMessage)")
        }
    }



    // MARK: - Private Helpers

    /// Firestoreにユーザー情報を保存
    private func saveUserData(userID: String, imageURL: String?) async throws {
        let userData: [String: Any] = [
            "id": userID,
            "email": email,                        // email を保存
            "iconURL": imageURL ?? "default-icon-url" // デフォルトURL
        ]
        print("⭐️AuthViewModelで保存するデータ: \(userData)") // デバッグ用
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
