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
        VStack(spacing: 16) {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            // アルバムから画像を選択
            if let selectedImage = authViewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    .padding(.bottom)
            } else {
                PhotosPicker(selection: Binding(
                    get: { nil },
                    set: { newItem in
                        if let newItem {
                            Task {
                                authViewModel.selectedImage = await loadImage(item: newItem)
                            }
                        }
                    }
                )) {
                    Text("Select Profile Image")
                        .foregroundColor(.blue)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
            }

            CustomTextField(placeholder: "Email", text: $authViewModel.email)
            CustomSecureField(placeholder: "Password", text: $authViewModel.password)

            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: {
                Task {
                    await authViewModel.signUp()
                    if authViewModel.isAuthenticated {
                        appState.screenState = .home
                    }
                }
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: {
                appState.screenState = .login
            }) {
                Text("Already have an account? Log In")
                    .foregroundColor(.blue)
            }
        }
        .glassmorphismBackground(
                    start: Color(hex: "91DDCF"),
                    end: Color(hex: "F19ED2"),
                    blurRadius: 20,
                    opacity: 0.25
                )
        .padding()
        .frame(maxWidth: 400)
    }

    // PhotosPickerからUIImageを読み込む
    private func loadImage(item: PhotosPickerItem) async -> UIImage? {
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                return UIImage(data: data)
            }
        } catch {
            print("画像の読み込みエラー: \(error.localizedDescription)")
        }
        return nil
    }
}
