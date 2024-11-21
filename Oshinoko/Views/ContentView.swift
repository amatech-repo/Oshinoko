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
