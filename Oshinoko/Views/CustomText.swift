//
//  CustomText.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/20.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.5)) // 半透明の白色背景
                    .shadow(radius: 7)
            )
            .autocapitalization(.none)
            .disableAutocorrection(true)

    }
}

struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.5)) // 半透明の白色背景
                    .shadow(radius: 7)
            )
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
}

