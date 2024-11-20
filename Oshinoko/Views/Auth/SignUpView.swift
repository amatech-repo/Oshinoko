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
                .foregroundColor(.white)
                .padding(.bottom, 20)

            if let selectedImage = authViewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(radius: 10)
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
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                                .shadow(radius: 5)
                        )
                }
            }

            CustomTextField(placeholder: "Email", text: $authViewModel.email)
                .padding()
            CustomSecureField(placeholder: "Password", text: $authViewModel.password)
                .padding()

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
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "F19ED2").opacity(0.7))
                            .shadow(radius: 5)
                    )
                    .foregroundColor(.white)
            }
            .padding()

            Button(action: {
                appState.screenState = .login
            }) {
                Text("Already have an account? Log In")
                    .font(.footnote)
            }
            .padding()
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassmorphismBackground(
            colors: [Color(hex: "91DDCF"), Color(hex: "F19ED2")]
        )
        .frame(maxWidth: 400)
    }

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
