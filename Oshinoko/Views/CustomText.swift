//
//  CustomText.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/20.
//

import SwiftUI
import _PhotosUI_SwiftUI

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

struct CustomButton: View {
    let title: String
    let action: () -> Void
    let backgroundColor: Color
    let opacity: Double

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor.opacity(opacity))
                        .shadow(radius: 5)
                )
                .foregroundColor(.white)
        }
        .padding()
    }
}

struct ProfileImagePicker: View {
    @Binding var selectedImage: UIImage?

    var body: some View {
        if let image = selectedImage {
            Image(uiImage: image)
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
                            selectedImage = await loadImage(item: newItem)
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
    }

    private func loadImage(item: PhotosPickerItem) async -> UIImage? {
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                return UIImage(data: data)
            }
        } catch {
            print("Image loading error: \(error.localizedDescription)")
        }
        return nil
    }
}

import SwiftUI

struct CustomText: View {
    var text: String
    var font: Font = .body
    var foregroundColor: Color = .white
    var shadowColor: Color = .black.opacity(0.9)
    var shadowRadius: CGFloat = 2

    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(foregroundColor)
    }
}
