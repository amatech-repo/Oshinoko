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
}

struct ContentView: View {
    @State private var screenState: ScreenState = .login

    var body: some View {
        VStack {
            switch screenState {
            case .login:
                LoginView(screenState: $screenState)
            case .signUp:
                SignUpView(screenState: $screenState)
            }
        }
    }
}

#Preview {
    ContentView()
}
