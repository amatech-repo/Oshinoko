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

struct ContentView: View {
    @State private var screenState: ScreenState = .login
    @StateObject private var authViewModel = AuthViewModel() // AuthViewModel のインスタンスを共有

    var body: some View {
        VStack {
            switch screenState {
            case .login:
                LoginView(authViewModel: authViewModel, screenState: $screenState)
            case .signUp:
                SignUpView(authViewModel: authViewModel, screenState: $screenState)
            case .home:
                HomeView()
            }
        }
    }
}

#Preview {
    ContentView()
}
