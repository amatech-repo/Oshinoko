//
//  SignUpView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//
import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        VStack {
            // 入力フィールド
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            // エラーメッセージ
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            // 新規登録ボタン
            Button("Sign Up") {
                viewModel.signUp()
            }
            .padding()

            // ログイン画面へのリンク
            NavigationLink("Already have an account? Log In", destination: LoginView())
                .padding()
                .foregroundColor(.blue)
        }
        .padding()
        .navigationTitle("Sign Up")
    }
}
