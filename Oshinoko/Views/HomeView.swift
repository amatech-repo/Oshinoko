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
        MapView(destination: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125))

    }
}

#Preview {
    HomeView()
}
