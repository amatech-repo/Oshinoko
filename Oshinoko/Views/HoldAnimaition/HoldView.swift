//
//  HoldView.swift
//  Oshinoko
//
//  Created by 神山颯太 on 2024/12/08.
//

import SwiftUI

struct HoldView: View {
    var body: some View {
      HoldAnimationView(lottieFile: "HoldAnimation")
            .frame(width:250,height: 250)
    }
}

#Preview {
    HoldView()
}
