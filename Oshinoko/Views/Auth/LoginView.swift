//
//  LoginView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI

import SwiftUI

struct LoginView: View {
    @Binding var screenState: ScreenState

    var body: some View {
        VStack {
            TextField("Email", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Log In") {
                // ログイン処理
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
