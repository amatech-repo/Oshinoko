//
//  SignUpView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//
import SwiftUI
import PhotosUI

struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                ProfileImagePicker(selectedImage: $authViewModel.selectedImage)

                CustomTextField(placeholder: "Email", text: $authViewModel.email)
                    .padding()
                CustomSecureField(placeholder: "Password", text: $authViewModel.password)
                    .padding()

                CustomButton(
                    title: "Sign Up",
                    action: {
                        Task {
                            authViewModel.isProcessing = true // ローディング開始
                            await authViewModel.signUp()
                            authViewModel.isProcessing = false // ローディング終了
                            if authViewModel.isAuthenticated {
                                appState.screenState = .home
                            }
                        }
                    },
                    backgroundColor: authViewModel.isProcessing ? .gray : Color(hex: "F19ED2"), // 処理中はグレー
                    opacity: authViewModel.isProcessing ? 0.5 : 0.7 // 処理中は半透明
                )
                .disabled(authViewModel.isProcessing) // 処理中は無効化

                Button(action: {
                    appState.screenState = .login
                }) {
                    Text("Already have an account? Log In")
                        .font(.footnote)
                }
                .padding()
            }
            .glassmorphismBackground(colors: [Color(hex: "91DDCF"), Color(hex: "F19ED2")])
            .frame(maxWidth: 400)

            if authViewModel.isProcessing {
                LoadingOverlay() // ローディングオーバーレイ
            }
        }
    }
}



struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            LoadingAnimationView(lottieFile: "LoadingAnimation")
        }
    }
}
