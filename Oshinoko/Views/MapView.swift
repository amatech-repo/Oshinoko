import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var mapView: MKMapView
    @ObservedObject var pinsViewModel: PinsViewModel
    @Binding var selectedPin: Pin?

    func makeUIView(context: Context) -> MKMapView {
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
        Coordinator(self, pinsViewModel: pinsViewModel)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var pinsViewModel: PinsViewModel

        init(_ parent: MapView, pinsViewModel: PinsViewModel) {
            self.parent = parent
            self.pinsViewModel = pinsViewModel
        }

        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }

            let location = gesture.location(in: parent.mapView)
            let coordinate = parent.mapView.convert(location, toCoordinateFrom: parent.mapView)

            let newPin = Pin(
                coordinate: Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude),
                metadata: Metadata(
                    createdBy: "User123",
                    description: "Description", title: "New Pin"
                )
            )

            Task {
                do {
                    try await pinsViewModel.addPin(coordinate: newPin.coordinate, metadata: newPin.metadata)
                } catch {
                    print("Failed to add pin: \(error.localizedDescription)")
                }
            }
        }

        @MainActor func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MKPointAnnotation else { return }

            if let tappedPin = pinsViewModel.pins.first(where: {
                $0.coordinate.latitude == annotation.coordinate.latitude &&
                $0.coordinate.longitude == annotation.coordinate.longitude
            }) {
                parent.selectedPin = tappedPin
            }
        }
    }
}

