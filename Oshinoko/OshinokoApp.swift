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
    @StateObject private var pinsViewModel = PinsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(pinsViewModel: pinsViewModel)
                .environmentObject(appState)
        }
    }
}
