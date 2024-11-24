//
//  LoginView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                CustomTextField(placeholder: "Email", text: $authViewModel.email)
                    .padding()
                CustomSecureField(placeholder: "Password", text: $authViewModel.password)
                    .padding()

                CustomButton(
                    title: "Log In",
                    action: {
                        Task {
                            authViewModel.isProcessing = true // ローディング開始
                            await authViewModel.logIn()
                            authViewModel.isProcessing = false // ローディング終了
                            if authViewModel.isAuthenticated {
                                appState.screenState = .home
                            }
                        }
                    },
                    backgroundColor: authViewModel.isProcessing ? .gray : Color(hex: "91DDCF"), // 処理中はグレー
                    opacity: authViewModel.isProcessing ? 0.5 : 0.7 // 処理中は半透明
                )
                .disabled(authViewModel.isProcessing) // 処理中は無効化

                Button(action: {
                    appState.screenState = .signUp
                }) {
                    Text("Don't have an account? Sign Up")
                        .font(.footnote)
                }
            }
            .glassmorphismBackground(colors: [Color(hex: "91DDCF"), Color(hex: "E8C5E5")])

            if authViewModel.isProcessing {
                LoadingOverlay() // ローディングオーバーレイ
            }
        }
    }
}
