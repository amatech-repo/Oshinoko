import Foundation
import SwiftUI
import MapKit

class MapViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var annotations: [MapAnnotationItem] = []

    init() {
        // 日本の中心（例: 東京付近）
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917), // 東京
            span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0) // 全国を見渡せる範囲
        )
    }

    func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        let annotation = MapAnnotationItem(coordinate: coordinate, color: .green)
        annotations.append(annotation)
    }
}
