//
//  LoginView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        NavigationView {
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
                // ログインボタン
                Button("Log In") {
                    viewModel.logIn()
                }
                .padding()

                // 新規登録画面へのリンク
                NavigationLink("Don't have an account? Sign Up", destination: SignUpView())
                    .padding()
                    .foregroundColor(.blue)
            }
            .padding()
            .navigationTitle("Log In")
        }
    }
}
