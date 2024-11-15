import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var pinsViewModel: PinsViewModel
    @Binding var selectedPin: Pin?
    let onLongPress: (CLLocationCoordinate2D) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress)
        )
        mapView.addGestureRecognizer(longPressGesture)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // マップ上のアノテーションを更新
        uiView.removeAnnotations(uiView.annotations)

        for pin in pinsViewModel.pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate.toCLLocationCoordinate2D()
            annotation.title = pin.metadata.title
            uiView.addAnnotation(annotation)
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

        @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            let location = gesture.location(in: gesture.view)
            if let mapView = gesture.view as? MKMapView {
                let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
                parent.onLongPress(coordinate)
            }
        }

        @MainActor func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // ピンがタップされたときに処理を行う
            guard let annotation = view.annotation as? MKPointAnnotation else { return }
            if let pin = parent.pinsViewModel.pins.first(where: {
                $0.coordinate.toCLLocationCoordinate2D() == annotation.coordinate
            }) {
                parent.selectedPin = pin
            }
        }
    }
}
