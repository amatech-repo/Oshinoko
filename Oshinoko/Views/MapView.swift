import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var pinsViewModel: PinsViewModel
    @Binding var selectedPin: Pin?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handleLongPress(_:))
        )
        mapView.addGestureRecognizer(longPressGesture)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)

        let annotations = pinsViewModel.pins.map { pin -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)
            annotation.title = pin.metadata.title
            return annotation
        }

        print("Updating annotations: \(annotations.map { $0.coordinate })")
        uiView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            guard gesture.state == .began else { return }

            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

            let metadata = Metadata(
                createdBy: "User123",
                description: "A new pin",
                title: "New Pin"
            )

            Task {
                do {
                    // Firestoreにピンを追加
                    try await parent.pinsViewModel.addPin(coordinate: Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude), metadata: metadata)
                } catch {
                    print("Failed to add pin: \(error.localizedDescription)")
                }
            }
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MKPointAnnotation else { return }
            mapView.deselectAnnotation(annotation, animated: false)

            Task { @MainActor in
                if let tappedPin = parent.pinsViewModel.pins.first(where: {
                    $0.coordinate.latitude == annotation.coordinate.latitude &&
                    $0.coordinate.longitude == annotation.coordinate.longitude
                }) {
                    parent.selectedPin = tappedPin
                }
            }
        }
    }
}

