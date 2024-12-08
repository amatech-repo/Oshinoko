//
//  ErrorView.swift
//  Oshinoko
//
//  Created by 神山颯太 on 2024/12/07.
//

import SwiftUI

struct ErrorView: View {
    var body: some View {
        VStack{
            ErrorAnimationView(lottieFile: "ErrorAnimation")
                .frame(width: 250,height: 250)
        }
    }
}

#Preview {
    ErrorView()
}
