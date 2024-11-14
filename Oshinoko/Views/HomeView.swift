//
//  HomeView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @State private var selectedAnnotation: MapAnnotationItem? = nil
    @StateObject private var viewModel = MapViewModel()

    var body: some View {
        ZStack {
            MapView(viewModel: viewModel, selectedAnnotation: $selectedAnnotation)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(item: $selectedAnnotation) { annotation in
            ModalView(annotation: annotation)
        }
    }
}

struct ModalView: View {
    let annotation: MapAnnotationItem

    var body: some View {
        VStack {
            Text("ピンの詳細")
                .font(.headline)
            Text("緯度: \(annotation.coordinate.latitude)")
            Text("経度: \(annotation.coordinate.longitude)")
            Spacer()
        }
        .padding()
        .background(annotation.color.opacity(0.1))
    }
}
