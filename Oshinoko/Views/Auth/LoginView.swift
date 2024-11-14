//
//  LoginView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var screenState: ScreenState

    var body: some View {
        VStack {
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button("Log In") {
                authViewModel.logIn()
                if authViewModel.isAuthenticated {
                    screenState = .home
                }
            }
            .padding()

            Button("Don't have an account? Sign Up") {
                screenState = .signUp
            }
            .foregroundColor(.blue)
        }
        .padding()
    }
}
