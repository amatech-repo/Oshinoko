import Foundation
import MapKit

class MapViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var annotations: [MapAnnotationItem] = []
    @Published var route: MapRoute?

    private let locationManager = CLLocationManager()

    init(destination: CLLocationCoordinate2D) {
        self.region = MKCoordinateRegion(
            center: destination,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        setupDestinationAnnotation(destination)
    }

    func setupDestinationAnnotation(_ destination: CLLocationCoordinate2D) {
        annotations = [
            MapAnnotationItem(coordinate: destination, color: .red)
        ]
    }

    func fetchUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        if let location = locationManager.location {
            userLocation = location.coordinate
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            // ユーザー位置を注釈に追加
            annotations.append(MapAnnotationItem(coordinate: location.coordinate, color: .blue))
        }
    }

    func calculateRoute(to destination: CLLocationCoordinate2D) {
        guard let userLocation = userLocation else { return }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        MKDirections(request: request).calculate { [weak self] response, error in
            guard let route = response?.routes.first else { return }
            self?.route = MapRoute(
                polyline: route.polyline,
                distance: route.distance,
                expectedTravelTime: route.expectedTravelTime
            )
        }
    }
}
