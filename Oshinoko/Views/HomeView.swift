//
//  HomeView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI
import MapKit

struct HomeView: View {
    var body: some View {
        MapView(viewModel: MapViewModel())
            .edgesIgnoringSafeArea(.all) // 地図を全画面表示
    }
}

#Preview {
    HomeView()
}
