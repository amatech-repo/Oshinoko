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
                        await authViewModel.logIn()
                        if authViewModel.isAuthenticated {
                            appState.screenState = .home
                        }
                    }
                },
                backgroundColor: Color(hex: "91DDCF"),
                opacity: 0.7
            )

            Button(action: {
                appState.screenState = .signUp
            }) {
                Text("Don't have an account? Sign Up")
                    .font(.footnote)
            }
        }
        .glassmorphismBackground(colors: [Color(hex: "91DDCF"), Color(hex: "E8C5E5")])
    }
}
