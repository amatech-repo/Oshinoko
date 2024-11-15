//
//  HomeView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @State private var selectedPin: Pin? // タップされたピン
    @State private var newPinCoordinate: CLLocationCoordinate2D? // 長押し位置
    @State private var isShowingInformationModal = false // 情報入力モーダル表示フラグ
    @StateObject private var chatViewModel = ChatViewModel(pinID: "") // ViewModelをHomeViewで保持
    @ObservedObject var pinsViewModel: PinsViewModel // StateObject → ObservedObject に修正


    var body: some View {
        ZStack {
            // カスタム MapView
            MapView(
                pinsViewModel: pinsViewModel,
                selectedPin: $selectedPin,
                onLongPress: { coordinate in
                    // 長押し時の処理
                    newPinCoordinate = coordinate
                    isShowingInformationModal = true
                }
            )
            .onAppear {
                // 初回表示時にピン情報を取得
                Task {
                    await pinsViewModel.fetchPins()
                }
            }
        }
        .sheet(isPresented: $isShowingInformationModal) {
            // ピン作成モーダル
            if let coordinate = newPinCoordinate {
                InformationModal(
                    coordinate: coordinate,
                    createdBy: "User123", // ログイン中のユーザーID
                    onSave: { metadata in
                        Task {
                            do {
                                try await pinsViewModel.addPin(
                                    coordinate: Coordinate(
                                        latitude: coordinate.latitude,
                                        longitude: coordinate.longitude
                                    ),
                                    metadata: metadata
                                )
                                newPinCoordinate = nil // 初期化
                                isShowingInformationModal = false
                            } catch {
                                print("Failed to add pin: \(error.localizedDescription)")
                            }
                        }
                    }
                )
            }
        }
        .sheet(item: $selectedPin) { pin in
            // ピン詳細モーダル
            PinDetailView(pin: pin, pinsViewModel: pinsViewModel) // ViewModelを渡す
        }
    }
}
