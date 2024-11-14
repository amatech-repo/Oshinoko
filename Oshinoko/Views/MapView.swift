import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel: MapViewModel
    @State private var showModal = false // モーダル表示状態

    init(destination: CLLocationCoordinate2D) {
        _viewModel = StateObject(wrappedValue: MapViewModel(destination: destination))
    }

    var body: some View {
        ZStack {
            Map(
                coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: viewModel.annotations
            ) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Button(action: {
                        viewModel.selectedAnnotation = item
                        showModal = true
                    }) {
                        Image(systemName: "star.fill") // 任意の画像に変更可能
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.yellow) // 色を変更可能
                    }
                }
            }
            .onAppear {
                viewModel.fetchUserLocation()
                viewModel.calculateRoute(to: viewModel.region.center)
            }
        }
        .sheet(isPresented: $showModal) {
            if let selectedAnnotation = viewModel.selectedAnnotation {
                AnnotationDetailView(annotation: selectedAnnotation)
            }
        }
    }
}
