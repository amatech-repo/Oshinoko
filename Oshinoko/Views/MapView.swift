import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    // MARK: - Properties
    @ObservedObject var pinsViewModel: PinsViewModel
    @Binding var selectedPin: Pin?
    @Binding var newPinCoordinate: CLLocationCoordinate2D?
    @Binding var isShowingModal: Bool
    let onLongPress: (CLLocationCoordinate2D) -> Void

    // MARK: - UIViewRepresentable Methods

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.addGestureRecognizer(createLongPressGesture(context: context))
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateAnnotations(on: uiView)
        updateOverlays(on: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Helpers

    private func createLongPressGesture(context: Context) -> UILongPressGestureRecognizer {
        UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress)
        )
    }

    private func updateAnnotations(on mapView: MKMapView) {
        let currentAnnotations = mapView.annotations.compactMap { $0 as? MKPointAnnotation }
        let newAnnotations = pinsViewModel.pins.map { pin -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate.toCLLocationCoordinate2D()
            annotation.title = pin.metadata.title
            return annotation
        }

        // 必要な差分のみ適用
        let currentSet = Set(currentAnnotations.map { $0.coordinate })
        let newSet = Set(newAnnotations.map { $0.coordinate })

        let toRemove = currentAnnotations.filter { !newSet.contains($0.coordinate) }
        let toAdd = newAnnotations.filter { !currentSet.contains($0.coordinate) }

        mapView.removeAnnotations(toRemove)
        mapView.addAnnotations(toAdd)
    }


    private func updateOverlays(on mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        if let route = pinsViewModel.currentRoute, pinsViewModel.isRouteDisplayed {
            mapView.addOverlay(route.polyline)
        }
    }

    class ImageCache {
        static let shared = NSCache<NSString, UIImage>()
    }


    // MARK: - Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        // MARK: - Long Press Handling
        @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            if let mapView = gesture.view as? MKMapView {
                let coordinate = mapView.convert(gesture.location(in: mapView), toCoordinateFrom: mapView)
                parent.newPinCoordinate = coordinate
                parent.isShowingModal = true
                parent.onLongPress(coordinate) // 必要に応じて外部処理を呼び出し
            }
        }

        // MARK: - Pin Selection Handling
        @MainActor func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MKPointAnnotation else { return }
            if let pin = parent.pinsViewModel.pins.first(where: {
                $0.coordinate.toCLLocationCoordinate2D() == annotation.coordinate
            }) {
                parent.selectedPin = pin
            }
        }

        @MainActor func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "Pin"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view?.canShowCallout = true
            } else {
                view?.annotation = annotation
            }

            if let pin = parent.pinsViewModel.pins.first(where: {
                $0.coordinate.latitude == annotation.coordinate.latitude &&
                $0.coordinate.longitude == annotation.coordinate.longitude
            }), let iconURLString = pin.iconURL, let iconURL = URL(string: iconURLString) {
                // キャッシュチェック
                if let cachedImage = ImageCache.shared.object(forKey: NSString(string: iconURLString)) {
                    view?.image = cachedImage
                } else {
                    // ダウンロードとキャッシュ保存
                    Task {
                        do {
                            let (data, _) = try await URLSession.shared.data(from: iconURL)
                            if let image = UIImage(data: data) {
                                let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 40, height: 40))
                                ImageCache.shared.setObject(resizedImage, forKey: NSString(string: iconURLString))
                                DispatchQueue.main.async {
                                    view?.image = resizedImage
                                }
                            }
                        } catch {
                            print("画像の取得エラー: \(error.localizedDescription)")
                        }
                    }
                }
            }

            return view
        }

        func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
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
}

extension Coordinate {
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

