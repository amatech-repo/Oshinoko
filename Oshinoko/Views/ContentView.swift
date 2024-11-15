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
    @ObservedObject var pinsViewModel: PinsViewModel
    @EnvironmentObject var appState: AppState
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        NavigationView {
            VStack {
                switch appState.screenState {
                case .login:
                    LoginView(authViewModel: authViewModel, screenState: $appState.screenState)
                case .signUp:
                    SignUpView(authViewModel: authViewModel, screenState: $appState.screenState)
                case .home:
                    HomeView(pinsViewModel: pinsViewModel)
                }
            }
        }
    }
}
