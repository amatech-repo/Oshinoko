import Foundation
import MapKit
import SwiftUI

class MapViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var annotations: [MapAnnotationItem] = []
    @Published var selectedAnnotation: MapAnnotationItem? // 選択された注釈を保持
    @Published var address: String? // 取得した住所を保持

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder() // 逆ジオコーディング用

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
            annotations.append(MapAnnotationItem(coordinate: location.coordinate, color: .blue))
        }
    }

    func fetchAddress(for coordinate: CLLocationCoordinate2D) {
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                self?.address = "住所を取得できませんでした"
                return
            }
            // 住所のフォーマットを構築
            self?.address = [
                placemark.name,
                placemark.locality,
                placemark.administrativeArea,
                placemark.country
            ].compactMap { $0 }.joined(separator: ", ")
        }
    }
}
