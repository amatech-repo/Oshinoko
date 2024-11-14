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
                        viewModel.fetchAddress(for: item.coordinate) // 住所を取得
                        showModal = true
                    }) {
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(item.color)
                    }
                }
            }
            .onAppear {
                viewModel.fetchUserLocation()
            }
        }
        .sheet(isPresented: $showModal) {
            if let selectedAnnotation = viewModel.selectedAnnotation {
                AnnotationDetailView(
                    annotation: selectedAnnotation,
                    address: viewModel.address
                )
            }
        }
    }
}
