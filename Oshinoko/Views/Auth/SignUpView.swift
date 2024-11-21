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

            ProfileImagePicker(selectedImage: $authViewModel.selectedImage)

            CustomTextField(placeholder: "Email", text: $authViewModel.email)
                .padding()
            CustomSecureField(placeholder: "Password", text: $authViewModel.password)
                .padding()


            CustomButton(
                title: "Sign Up",
                action: {
                    Task {
                        await authViewModel.signUp()
                        if authViewModel.isAuthenticated {
                            appState.screenState = .home
                        }
                    }
                },
                backgroundColor: Color(hex: "F19ED2"),
                opacity: 0.7
            )

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
    }
}
