//
//  ContentView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/13.
//

import SwiftUI

enum ScreenState {
    case login
    case signUp
    case home
}

class AppState: ObservableObject {
    @Published var screenState: ScreenState = .login
    @Published var isLoading: Bool = true

    func finishLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 2秒後にローディングを終了
            self.isLoading = false
        }
    }
}

struct ContentView: View {
    @StateObject private var appState = AppState()
    @StateObject private var authViewModel = AuthViewModel()
    @ObservedObject var pinsViewModel: PinsViewModel

    var body: some View {
        NavigationStack {
            switch appState.screenState {
            case .login:
                LoginView()
                    .environmentObject(appState)
                    .environmentObject(authViewModel)
            case .signUp:
                SignUpView()
                    .environmentObject(appState)
                    .environmentObject(authViewModel)
            case .home:
                HomeView(pinsViewModel: pinsViewModel)
                    .environmentObject(appState)
                    .environmentObject(authViewModel)
            }
        }
        .glassmorphismBackground(
            colors: [Color(hex: "91DDCF"), Color(hex: "E8C5E5")]
        )
    }
}
