import Foundation
import SwiftUI
import MapKit

class MapViewModel: NSObject, ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var annotations: [MapAnnotationItem] = []

    override init() {
        // 初期範囲（例: 東京駅付近）
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        super.init()
    }

    func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        print("Adding annotation at: \(coordinate)")
        annotations.append(MapAnnotationItem(coordinate: coordinate, color: .green))
    }
}
