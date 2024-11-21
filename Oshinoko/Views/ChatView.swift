//
//  ChatView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel // `@StateObject`に変更
    @State private var isImagePickerPresented = false
    let currentUserID: String
    let currentUserName: String
    let currentUserIcon: String?
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("読み込み中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.messages, id: \.wrappedID) { message in
                                HStack {
                                    if let icon = currentUserIcon, let url = URL(string: icon) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                    ChatMessageView(message: message, isCurrentUser: message.senderID == currentUserID)
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                HStack {
                    TextField("メッセージを入力", text: $viewModel.messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("送信") {
                        Task {
                            await viewModel.sendMessage(senderID: currentUserID)
                        }
                    }
                    .disabled(viewModel.messageText.isEmpty)
                }
                .padding()
            }
        }
        .onAppear {
            if viewModel.messages.isEmpty { // 初期状態でローディングを再開
                viewModel.startListeningForMessages()
            }
        }
        
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if !isCurrentUser {
                ProfileImageView(url: message.senderIconURL)
            }

            VStack(alignment: isCurrentUser ? .trailing : .leading) {
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
                }
            }

            if isCurrentUser {
                ProfileImageView(url: message.senderIconURL)
            }
        }
    }
}

struct ProfileImageView: View {
    let url: String?

    var body: some View {
        if let url = url, let imageURL = URL(string: url) {
            AsyncImage(url: imageURL) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 40, height: 40)
            }
        } else {
            Circle()
                .fill(Color.gray)
                .frame(width: 40, height: 40)
        }
    }
}
