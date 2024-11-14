import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel: MapViewModel

    init(destination: CLLocationCoordinate2D) {
        _viewModel = StateObject(wrappedValue: MapViewModel(destination: destination))
    }

    var body: some View {
        Map(
            coordinateRegion: $viewModel.region,
            showsUserLocation: true,
            annotationItems: viewModel.annotations
        ) { item in
            MapPin(coordinate: item.coordinate, tint: item.color)
        }
        .onAppear {
            viewModel.fetchUserLocation()
            viewModel.calculateRoute(to: viewModel.region.center)
        }
    }
}
