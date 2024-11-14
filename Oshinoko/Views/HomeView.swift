//
//  HomeView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var pinsViewModel = PinsViewModel()
    @State private var selectedPin: Pin?
    @State private var chatViewModel: ChatViewModel?

    var body: some View {
        ZStack {
            MapView(pinsViewModel: pinsViewModel, selectedPin: $selectedPin)
                .onAppear {
                    Task {
                        await pinsViewModel.fetchPins()
                    }
                }
                .onChange(of: selectedPin) { newPin in
                    // 選択されたピンが変更された場合に ChatViewModel を設定
                    if let newPin = newPin {
                        if let existingViewModel = chatViewModel, existingViewModel.pinID == newPin.id {
                            // 既存の ViewModel を使用
                            chatViewModel = existingViewModel
                        } else {
                            // 新しい ViewModel を作成
                            chatViewModel = ChatViewModel(pinID: newPin.id ?? "")
                        }
                    }
                }
                .sheet(item: $selectedPin) { pin in
                    if let viewModel = chatViewModel {
                        ChatView(viewModel: viewModel, currentUserID: "User123")
                    } else {
                        Text("Loading...")
                    }
                }
        }
    }
}

