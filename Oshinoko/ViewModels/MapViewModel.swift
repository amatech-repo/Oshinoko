import Foundation
import MapKit
import SwiftUI

class MapViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var annotations: [MapAnnotationItem] = []
    @Published var address: String? // 取得した住所を保持

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    init(destination: CLLocationCoordinate2D) {
        self.region = MKCoordinateRegion(
            center: destination,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
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

    // 地図のタップ位置を座標に変換してピンを追加
    func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        annotations.append(MapAnnotationItem(coordinate: coordinate, color: .green))
        fetchAddress(for: coordinate) // 住所を取得
    }

    // 座標から住所を取得
    func fetchAddress(for coordinate: CLLocationCoordinate2D) {
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                self?.address = "住所を取得できませんでした"
                return
            }
            self?.address = [
                placemark.name,
                placemark.locality,
                placemark.administrativeArea,
                placemark.country
            ].compactMap { $0 }.joined(separator: ", ")
        }
    }
}
