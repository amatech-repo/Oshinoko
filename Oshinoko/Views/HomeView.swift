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
    @State private var selectedPin: Pin?
    @State private var newPinCoordinate: CLLocationCoordinate2D?
    @State private var isShowingInformationModal = false
    @State private var selection = 1
    @State private var bookmarks: [Bookmark] = []
    @State private var searchQuery: String = "" // 検索クエリを追加

    // チュートリアル表示状態を AppStorage で管理
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial: Bool = false
    @State private var isTutorialVisible: Bool = false

    // MARK: - Observed ViewModels
    @StateObject private var chatViewModel = ChatViewModel(pinID: "")
    @ObservedObject var pinsViewModel: PinsViewModel

    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()

            TabView(selection: $selection) {
                mapTab
                    .tabItem {
                        CustomTabItem(icon: "map", text: "Map", isSelected: selection == 1)
                    }
                    .tag(1)

                AIChatView()
                    .tabItem {
                        CustomTabItem(icon: "message", text: "AI", isSelected: selection == 2)
                    }
                    .tag(2)

                BookmarksTab(bookmarks: $bookmarks)
                    .tabItem {
                        CustomTabItem(icon: "bookmark", text: "Bookmark", isSelected: selection == 3)
                    }
                    .tag(3)
            }
            .onAppear {
                configureTabBarAppearance() // タブの色設定を反映
            }
        }
        .glassmorphismBackground(colors: [Color(hex: "91DDCF"), Color(hex: "E8C5E5")])
    }

    // MARK: - Tab 1: Map Tab
    private var mapTab: some View {
        ZStack {
            VStack(spacing: 0) {
                MapView(
                    pinsViewModel: pinsViewModel,
                    selectedPin: $selectedPin,
                    newPinCoordinate: $newPinCoordinate,
                    isShowingModal: $isShowingInformationModal,
                    searchQuery: $searchQuery, onLongPress: { coordinate in
                        newPinCoordinate = coordinate
                        isShowingInformationModal = true
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: 790)
                .onAppear {
                    Task {
                        await pinsViewModel.fetchPins()
                    }
                }
                Spacer()
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
                            resetModalState()
                        }
                    )
                }
            }
            .sheet(item: $selectedPin) { pin in
                PinDetailView(pin: pin, pinsViewModel: pinsViewModel)
            }
            .glassmorphismBackground(colors: [Color(hex: "91DDCF"), Color(hex: "E8C5E5")])

            // チュートリアルオーバーレイを重ねる
            if isTutorialVisible {
                TutorialOverlay(isVisible: $isTutorialVisible)
            }
        }
        .onAppear {
            if !hasSeenTutorial {
                isTutorialVisible = true
            }
        }
        .onChange(of: isTutorialVisible) { newValue in
            if !newValue {
                hasSeenTutorial = true // チュートリアルが閉じられたらフラグを更新
            }
        }
    }

    private func resetModalState() {
        newPinCoordinate = nil
        isShowingInformationModal = false
    }

    // MARK: - Tab Bar Appearance
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()

        // 背景を透明感のあるピンク色に設定
        let backgroundColor = UIColor(named: "F19ED2")?.withAlphaComponent(0.8) ?? UIColor(red: 241/255, green: 158/255, blue: 210/255, alpha: 0.3)
        appearance.backgroundColor = backgroundColor

        // タブの影を削除してスムーズにする
        appearance.shadowImage = UIImage()
        appearance.shadowColor = nil

        // すべてのスタイルに適用
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
    }
}

// MARK: - CustomTabItem
struct CustomTabItem: View {
    let icon: String
    let text: String
    let isSelected: Bool

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isSelected ? Color(hex: "F19ED2") : .white.opacity(0.9))
                .padding()
                .background(
                    Circle()
                        .fill(isSelected ? Color(hex: "F19ED2").opacity(0.2) : Color.clear)
                        .shadow(color: isSelected ? Color(hex: "F19ED2").opacity(0.7) : Color.clear, radius: isSelected ? 5 : 0)
                )
            CustomText(
                text: text,
                font: .caption,
                foregroundColor: isSelected ? Color(hex: "F19ED2") : .white.opacity(0.7)
            )
        }
        .frame(maxWidth: .infinity)
    }
}


