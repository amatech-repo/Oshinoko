//
//  ChatView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @State private var isImagePickerPresented = false // 画像選択モーダル表示
    let currentUserID: String

    init(pinID: String, currentUserID: String) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(pinID: pinID))
        self.currentUserID = currentUserID
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.senderID == currentUserID {
                                Spacer()
                                if message.isImage, let imageURL = message.imageURL {
                                    AsyncImage(url: URL(string: imageURL)) { image in
                                        image.resizable().scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(maxWidth: 250)
                                } else {
                                    Text(message.message)
                                        .padding()
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(8)
                                        .frame(maxWidth: 250, alignment: .trailing)
                                }
                            } else {
                                if message.isImage, let imageURL = message.imageURL {
                                    AsyncImage(url: URL(string: imageURL)) { image in
                                        image.resizable().scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(maxWidth: 250)
                                } else {
                                    Text(message.message)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .frame(maxWidth: 250, alignment: .leading)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)

            HStack {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $viewModel.selectedImage)
                }

                TextField("メッセージを入力", text: $viewModel.messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40)

                Button("送信") {
                    if let image = viewModel.selectedImage {
                        Task {
                            await viewModel.uploadImage(image: image, senderID: currentUserID)
                            viewModel.selectedImage = nil // 選択状態をリセット
                        }
                    } else {
                        Task {
                            await viewModel.sendMessage(senderID: currentUserID)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .padding()
    }
}
