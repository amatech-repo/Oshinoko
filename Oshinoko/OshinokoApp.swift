//
//  OshinokoApp.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/13.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure() // Firebase の初期化
        return true
    }
}

@main
struct OshinokoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()
    @StateObject private var authViewModel = AuthViewModel() // クラス名を統一
    @StateObject private var pinsViewModel = PinsViewModel(authViewModel: AuthViewModel.shared) // 正しい型を渡す

    var body: some Scene {
        WindowGroup {
            if appState.isLoading {
                LoadingView()
                    .onAppear {
                        appState.finishLoading() // ローディングを開始
                    }
            } else {
                ContentView(pinsViewModel: pinsViewModel)
                    .environmentObject(appState)
                    .environmentObject(authViewModel)
            }
        }
    }
}
