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
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
            Text("アプリを準備中です…")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground)) // 背景色を設定
        .ignoresSafeArea() // 安全領域を無視
    }
}


#Preview {
    LoadingView()
}
