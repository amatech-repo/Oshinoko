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
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var shouldZoom = false // ズームを制御するフラグ




    // MARK: - Observed ViewModels
    @StateObject private var chatViewModel = ChatViewModel(pinID: "")
    @ObservedObject var pinsViewModel: PinsViewModel
    @State private var isTutorialVisible: Bool = true

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

                BookmarksTab(
                    bookmarks: $bookmarks,
                    selectedCoordinate: $selectedCoordinate,
                    tabSelection: $selection, // タブ切り替え用
                    shouldZoom: $shouldZoom
                )
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
                    isShowingModal: $isShowingInformationModal, // 修正: Bool 型
                    selectedCoordinate: $selectedCoordinate,   // 修正: CLLocationCoordinate2D? 型
                    shouldZoom: $shouldZoom,                   // 修正: ズームフラグ
                    onLongPress: { coordinate in
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
            checkTutorialVisibility() // チュートリアル表示状態を確認
        }
    }

    private func checkTutorialVisibility() {
        let hasSeenTutorial = UserDefaults.standard.bool(forKey: "hasSeenTutorial")
        isTutorialVisible = !hasSeenTutorial // チュートリアルを未表示の場合のみ表示
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


struct TutorialOverlay: View {
    @State private var tapCount: Int = 0
    @Binding var isVisible: Bool // 表示状態を管理

    let maxTaps: Int = 3 // タップ回数の上限

    private let messages = [
        "ねぇねぇ！地図の空いてる場所を長押ししてみて！ピンが立てられるんだよ！共有もできちゃう！",
        "ほら、地図にあるアイコンをタップしてみて！観光地やみんなのコメントが見れるよ！",
        "さぁ、君もおすすめのスポットにピンを立てて、みんなに教えてあげよう！"
    ]
    
    private let images = [
        "Map_tutorial1",
        "Map_Tutorial3",
        "Detail_Tutorail",
    ]

    var body: some View {
        ZStack {
            // 透明な背景
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    handleTap()
                }

            // メッセージ表示
            if tapCount < messages.count {
                
                Rectangle()
                    .frame(width: 325,height:675)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    
                    .padding()
                VStack{
                    ZStack{
                        Image(images[tapCount])
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(25)
                        
                        if (tapCount < 2){
                            HoldAnimationView(lottieFile: "hold")
                                .frame(width:100 , height: 100)
                                .offset(x: -30,y:20)
                        }
                        
                        
                        Text(messages[tapCount])
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(10)
                            .multilineTextAlignment(.center)
                            .padding()
                            .offset(y: -150)
                        
                    }
                    .frame(width:300,height:600)
                    .padding()
                    
                    if(tapCount == 0) {
                        Text("⚫︎  ⚪︎  ⚪︎")
                    } else if (tapCount == 1) {
                        Text("⚪︎  ⚫︎  ⚪︎")
                    } else {
                        Text("⚪︎  ⚪︎  ⚫︎")
                    }
                }
            }
        }
        .opacity(isVisible ? 1 : 0) // 表示状態に応じて透明度を変更
        .animation(.easeInOut, value: isVisible) // アニメーション
        .transition(.opacity) // フェードイン・アウトのトランジション
    }

    private func handleTap() {
        tapCount += 1
        if tapCount >= maxTaps {
            withAnimation {
                isVisible = false // 非表示にする
                saveTutorialSeenFlag() // 表示済みフラグを設定
            }
        }
    }

    private func saveTutorialSeenFlag() {
        UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
    }
}
