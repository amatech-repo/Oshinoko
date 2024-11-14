//
//  SignUpView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//
import SwiftUI

struct SignUpView: View {
    @Binding var screenState: ScreenState

    var body: some View {
        VStack {
            TextField("Email", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Sign Up") {
                // 新規登録処理
            }
            .padding()
            Button("Already have an account? Log In") {
                screenState = .login
            }
            .foregroundColor(.blue)
        }
        .padding()
    }
}

