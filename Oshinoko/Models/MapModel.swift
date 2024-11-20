
import Foundation
import CoreLocation
import SwiftUI
import MapKit

// 注釈用のデータモデル
struct MapAnnotationItem: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let color: Color
    
    init(id: UUID = UUID(), coordinate: CLLocationCoordinate2D, color: Color) {
        self.id = id
        self.coordinate = coordinate
        self.color = color
    }
}

// ルート情報を格納するモデル
struct MapRoute {
    let polyline: MKPolyline
    let distance: Double
    let expectedTravelTime: Double
}
