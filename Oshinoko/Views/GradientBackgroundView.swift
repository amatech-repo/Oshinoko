//
//  GradientBackgroundView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/19.
//

import SwiftUI

struct GlassmorphismBackground: ViewModifier {
    let startColor: Color
    let endColor: Color
    let blurRadius: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                gradient: Gradient(colors: [startColor, endColor]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 半透明のガラスレイヤー
            Color.white
                .opacity(opacity)
                .blur(radius: blurRadius)
                .ignoresSafeArea()

            content // コンテンツのレイヤー
        }
    }
}

extension View {
    func glassmorphismBackground(
        start: Color,
        end: Color,
        blurRadius: CGFloat = 10,
        opacity: Double = 0.3
    ) -> some View {
        self.modifier(GlassmorphismBackground(startColor: start, endColor: end, blurRadius: blurRadius, opacity: opacity))
    }
}
// MARK: - Hexカラーコードを使うための便利な拡張
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
