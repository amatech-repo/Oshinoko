//
//  ChatView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @State private var isImagePickerPresented = false
    @State private var scrollViewProxy: ScrollViewProxy?
    let currentUserID: String

    init(pinID: String, currentUserID: String) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(pinID: pinID))
        self.currentUserID = currentUserID
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            ChatMessageView(message: message, isCurrentUser: message.senderID == currentUserID)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    scrollViewProxy = proxy
                }
            }

            if viewModel.isLoading {
                ProgressView("送信中…")
                    .padding()
            }

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

                Button("送信", action: {
                    Task {
                        await viewModel.sendMessage(senderID: currentUserID)
                    }
                })
                .disabled(viewModel.messageText.isEmpty)
                .padding(.horizontal)
            }
            .padding()
        }
        .padding()
        .alert(item: $viewModel.errorMessage) { error in
            Alert(title: Text("エラー"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
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
                    .background(isCurrentUser ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)
            }
            if !isCurrentUser { Spacer() }
        }
    }
}
