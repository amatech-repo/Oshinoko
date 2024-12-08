import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    // MARK: - Properties
    @ObservedObject var pinsViewModel: PinsViewModel
    @Binding var selectedPin: Pin?
    @Binding var newPinCoordinate: CLLocationCoordinate2D?
    @Binding var isShowingModal: Bool
    @Binding var searchQuery: String
    let onLongPress: (CLLocationCoordinate2D) -> Void

    // MARK: - UIViewRepresentable Methods
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()

        // MapView
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.addGestureRecognizer(createLongPressGesture(context: context))
        mapView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(mapView)

        // SearchBar
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "場所を検索"
        searchBar.showsCancelButton = true // キャンセルボタンを表示
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(searchBar)

        // Layout
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: containerView.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        context.coordinator.mapView = mapView
        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let mapView = context.coordinator.mapView {
            updateAnnotations(on: mapView)
            updateOverlays(on: mapView)
        }
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
        let newAnnotations = pinsViewModel.pins.map { pin in
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate.toCLLocationCoordinate2D()
            annotation.title = pin.metadata.title
            return annotation
        }

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

    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate, UISearchBarDelegate {
        var parent: MapView
        weak var mapView: MKMapView?
        private var localSearch: MKLocalSearch?

        init(_ parent: MapView) {
            self.parent = parent
        }

        // MARK: - Long Press Handling
        @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began, let mapView = gesture.view as? MKMapView else { return }
            let coordinate = mapView.convert(gesture.location(in: mapView), toCoordinateFrom: mapView)
            parent.newPinCoordinate = coordinate
            parent.isShowingModal = true
            parent.onLongPress(coordinate)
        }

        // MARK: - Pin Selection
        @MainActor func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MKPointAnnotation else { return }
            if let pin = parent.pinsViewModel.pins.first(where: {
                $0.coordinate.toCLLocationCoordinate2D() == annotation.coordinate
            }) {
                parent.selectedPin = pin
            }
        }

        // MARK: - Overlay Renderer
        @MainActor func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.blue.withAlphaComponent(0.7) // 経路の色
                renderer.lineWidth = 5 // 経路の幅
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        // MARK: - Annotation View
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
                if let cachedImage = ImageCache.shared.object(forKey: NSString(string: iconURLString)) {
                    view?.image = cachedImage
                } else {
                    Task {
                        do {
                            let (data, _) = try await URLSession.shared.data(from: iconURL)
                            if let image = UIImage(data: data) {
                                let circularImage = makeCircularImage(image: image, size: CGSize(width: 40, height: 40))
                                ImageCache.shared.setObject(circularImage, forKey: NSString(string: iconURLString))
                                DispatchQueue.main.async {
                                    view?.image = circularImage
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

        // MARK: - Search Handling
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            guard let query = searchBar.text, !query.isEmpty else {
                print("検索クエリが空です")
                return
            }
            print("検索開始: \(query)")
            searchBar.resignFirstResponder() // キーボードを閉じる
            performSearch(query: query)
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder() // キーボードを閉じる
            searchBar.text = nil // 検索クエリをクリア
        }



        private func performSearch(query: String) {
            guard let mapView = mapView else {
                print("MapViewが見つかりません")
                return
            }

            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = mapView.region

            localSearch?.cancel()
            localSearch = MKLocalSearch(request: request)
            localSearch?.start { [weak self] response, error in
                guard let self = self else { return }

                if let error = error {
                    print("検索エラー: \(error.localizedDescription)")
                    return
                }

                guard let response = response else {
                    print("検索結果がありません")
                    return
                }

                print("検索結果: \(response.mapItems.count) 件")
                self.updateMapWithSearchResults(response: response)
            }
        }

        private func updateMapWithSearchResults(response: MKLocalSearch.Response) {
            guard let mapView = mapView else { return }
            mapView.removeAnnotations(mapView.annotations)

            let annotations = response.mapItems.map { item -> MKPointAnnotation in
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                annotation.subtitle = item.placemark.title // 詳細情報
                return annotation
            }

            mapView.addAnnotations(annotations)

            if let firstItem = response.mapItems.first {
                let region = MKCoordinateRegion(
                    center: firstItem.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
                mapView.setRegion(region, animated: true)
            }
        }

        // MARK: - Image Helpers
        func makeCircularImage(image: UIImage, size: CGSize) -> UIImage {
            let resizedImage = resizeImageWithAspectFit(image: image, targetSize: size)
            let diameter = min(size.width, size.height)
            let bounds = CGRect(x: 0, y: 0, width: diameter, height: diameter)

            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
            let context = UIGraphicsGetCurrentContext()

            context?.addEllipse(in: bounds)
            context?.clip()
            resizedImage.draw(in: bounds)

            let circularImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return circularImage ?? resizedImage
        }

        func resizeImageWithAspectFit(image: UIImage, targetSize: CGSize) -> UIImage {
            let widthRatio = targetSize.width / image.size.width
            let heightRatio = targetSize.height / image.size.height
            let scale = min(widthRatio, heightRatio)
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return resizedImage ?? image
        }
    }
}

// MARK: - ImageCache
class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

// MARK: - Extensions
extension Coordinate {
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

