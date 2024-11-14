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
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            Button("Sign Up") {
                viewModel.signUp()
            }
            .padding()
        }
        .padding()
        .fullScreenCover(isPresented: $viewModel.isAuthenticated) {
            Text("Account Created!").font(.largeTitle)
        }
    }
}
