//
//  HomeView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI
import MapKit

struct HomeView: View {
    // MARK: - State Properties
    @State private var selectedPin: Pin? // タップされたピン
    @State private var newPinCoordinate: CLLocationCoordinate2D? // 長押し位置の座標
    @State private var isShowingInformationModal = false // 情報入力モーダルの表示フラグ
    @State var selection = 1 // タブ選択状態
    @State private var bookmarks: [Bookmark] = []


    // MARK: - Observed ViewModels
    @StateObject private var chatViewModel = ChatViewModel(pinID: "") // Chat用ViewModel
    @ObservedObject var pinsViewModel: PinsViewModel // ピン管理用ViewModel
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景色を設定
            Color.red
                .ignoresSafeArea() // 安全領域を無視して全体に適用
            
            // コンテンツ (TabView)
            TabView(selection: $selection) {
                mapTab
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                    .tag(1)
                
                textTab(title: "Tab 2 Content")
                    .tabItem {
                        Label("AI", systemImage: "message")
                    }
                    .tag(2)
                
                textTab(title: "Tab 3 Content")
                    .tabItem {
                        Label("Bookmark", systemImage: "person")
                    }
                    .tag(3)
            }
        }
    }
    
    // MARK: - Tab 1: Map Tab
    private var mapTab: some View {
        VStack(spacing: 0) {
            ZStack {
                // カスタム MapView
                MapView(
                    pinsViewModel: pinsViewModel,
                    selectedPin: $selectedPin,
                    newPinCoordinate: $newPinCoordinate, isShowingModal: $isShowingInformationModal,
                    onLongPress: { coordinate in
                        newPinCoordinate = coordinate
                        isShowingInformationModal = true
                    }
                )
                .frame(height: 720) // MapViewの高さを制限
                .frame(maxWidth: .infinity)
                .padding(.bottom)
                .onAppear {
                    Task {
                        await pinsViewModel.fetchPins()
                    }
                }
            }
            
            Spacer() // タブバーを見やすくするためにスペースを調整
        }
        .sheet(isPresented: $isShowingInformationModal) {
            if let coordinate = newPinCoordinate {
                InformationModal(
                    coordinate: coordinate,
                    onSave: { metadata in
                        Task {
                            await pinsViewModel.addPin(
                                coordinate: Coordinate(
                                    latitude: coordinate.latitude,
                                    longitude: coordinate.longitude
                                ),
                                metadata: metadata
                            )
                        }
                        newPinCoordinate = nil
                        isShowingInformationModal = false
                    }
                )
            }
        }
        
        .sheet(item: $selectedPin) { pin in
            PinDetailView(pin: pin, pinsViewModel: pinsViewModel)
        }
    }
    
    // MARK: - Helper Functions
    private func createPinModal(for coordinate: CLLocationCoordinate2D) -> some View {
        InformationModal(
            coordinate: coordinate,
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
                        newPinCoordinate = nil
                        isShowingInformationModal = false
                    } catch {
                        print("Failed to add pin: \(error.localizedDescription)")
                    }
                }
            }
        )
    }
    
    
    // MARK: - Tab 2 and Tab 3: Placeholder Views
    private func textTab(title: String) -> some View {
        List(bookmarks, id: \.self) { bookmark in
            VStack(alignment: .leading) {
                Text(bookmark.address ?? "住所なし")
                Text("座標: \(bookmark.latitude), \(bookmark.longitude)")
                    .font(.caption)
            }
        }
        .onAppear {
            bookmarks = CoreDataManager.shared.fetchBookmarks()

        }
        .background(Color(.systemBackground)) // タブごとに背景色を統一
    }
}

