//
//  AddListView.swift
//  Oshinoko
//
//  Created by 神山颯太 on 2024/12/07.
//

import SwiftUI

struct AddListView: View {
    var body: some View {
        VStack{
            AddListAnimationView(lottieFile: "AddList")
                .frame(width: 200 , height: 200)
        }
    }
}

#Preview {
    AddListView()
}
