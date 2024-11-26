//
//  LoadingView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            LoadingAnimationView(lottieFile: "LoadingAnimation")
                .frame(width: 400, height: 400)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassmorphismBackground(colors: [Color(hex: "91DDCF"), Color(hex: "E8C5E5")])// 背景色を設定
        .ignoresSafeArea() // 安全領域を無視
    }
}


#Preview {
    LoadingView()
}
