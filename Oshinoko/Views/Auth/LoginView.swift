//
//  LoginView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            CustomTextField(placeholder: "Email", text: $authViewModel.email)
            CustomSecureField(placeholder: "Password", text: $authViewModel.password)

            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: {
                Task {
                    await authViewModel.logIn()
                    if authViewModel.isAuthenticated {
                        appState.screenState = .home
                    }
                }
            }) {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: {
                appState.screenState = .signUp
            }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
        }
        .glassmorphismBackground(
                    start: Color(hex: "91DDCF"),
                    end: Color(hex: "E8C5E5"),
                    blurRadius: 20,
                    opacity: 0.25
                )
        .padding()
        .frame(maxWidth: 400)
    }
}
