import SwiftUI
import FirebaseCore
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var pinsViewModel: PinsViewModel
    @Binding var selectedPin: Pin?
    let onLongPress: (CLLocationCoordinate2D) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        // 長押しジェスチャーを設定
        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress)
        )
        mapView.addGestureRecognizer(longPressGesture)

        // クラスタリングの設定 (iOS 11 以降)
        if #available(iOS 11.0, *) {
            mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        }

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let currentAnnotations = uiView.annotations.compactMap { $0 as? MKPointAnnotation }
        let newAnnotations = pinsViewModel.pins.map { pin -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate.toCLLocationCoordinate2D()
            annotation.title = pin.metadata.title
            return annotation
        }

        // アノテーションの追加と削除
        let toRemove = currentAnnotations.filter { !newAnnotations.contains($0) }
        let toAdd = newAnnotations.filter { !currentAnnotations.contains($0) }

        uiView.removeAnnotations(toRemove)
        uiView.addAnnotations(toAdd)

        // 経路の更新
        if let route = pinsViewModel.currentRoute, pinsViewModel.isRouteDisplayed {
            if !uiView.overlays.contains(where: { $0 is MKPolyline }) {
                uiView.addOverlay(route.polyline)
            }
        } else {
            uiView.removeOverlays(uiView.overlays)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        @objc @MainActor
        func handleLongPress(gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            let location = gesture.location(in: gesture.view)
            if let mapView = gesture.view as? MKMapView {
                let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
                Task {
                    let metadata = Metadata(createdBy: "User123", description: "Added by user", title: "New Pin")
                    let newCoordinate = Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    await parent.pinsViewModel.addPin(coordinate: newCoordinate, metadata: metadata)
                }
            }
        }


        @MainActor func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MKPointAnnotation else { return }
            if let pin = parent.pinsViewModel.pins.first(where: {
                parent.pinsViewModel.areCoordinatesEqual($0.coordinate.toCLLocationCoordinate2D(), annotation.coordinate)
            }) {
                parent.selectedPin = pin
            }
        }

        // オーバーレイ描画のデリゲート
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }

    static func dismantleUIView(_ uiView: MKMapView, coordinator: Coordinator) {
        // UIViewRepresentable が破棄される際のリソース解放
        uiView.delegate = nil
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)
        uiView.layer.removeAllAnimations() // Metal レイヤーのアニメーションを停止
        print("MapView dismantled")
    }
}

