import SwiftUI
import FirebaseCore
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var pinsViewModel: PinsViewModel
    @Binding var selectedPin: Pin?
    @Binding var newPinCoordinate: CLLocationCoordinate2D? // 必要なプロパティを追加
    @Binding var isShowingModal: Bool // 必要なプロパティを追加
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
        
        // アノテーションビューのカスタマイズ
        @MainActor func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? MKPointAnnotation else { return nil }
            
            let identifier = "CustomAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKAnnotationView
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            // ピンに対応するユーザーのアイコン画像を設定
            if let pin = parent.pinsViewModel.pins.first(where: {
                parent.pinsViewModel.areCoordinatesEqual($0.coordinate.toCLLocationCoordinate2D(), annotation.coordinate)
            }), let iconURL = pin.iconURL, let url = URL(string: iconURL) {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                imageView.layer.cornerRadius = 20
                imageView.layer.masksToBounds = true
                
                // 非同期で画像を読み込み
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    }
                }
                
                annotationView?.addSubview(imageView)
                annotationView?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            } else {
                annotationView?.image = UIImage(systemName: "mappin.circle")
            }
            
            return annotationView
        }
        
        @objc @MainActor
        func handleLongPress(gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            let location = gesture.location(in: gesture.view)
            if let mapView = gesture.view as? MKMapView {
                let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
                parent.newPinCoordinate = coordinate
                parent.isShowingModal = true
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

extension Coordinate {
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
