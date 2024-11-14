import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    @Binding var selectedAnnotation: MapAnnotationItem?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handleLongPress(_:))
        )
        mapView.addGestureRecognizer(longPressGesture)

        mapView.setRegion(viewModel.region, animated: true)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)

        for annotation in viewModel.annotations {
            let pin = MKPointAnnotation()
            pin.coordinate = annotation.coordinate
            pin.title = annotation.id.uuidString // 一意のIDを設定
            uiView.addAnnotation(pin)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel, selectedAnnotation: $selectedAnnotation)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var viewModel: MapViewModel
        @Binding var selectedAnnotation: MapAnnotationItem?

        init(viewModel: MapViewModel, selectedAnnotation: Binding<MapAnnotationItem?>) {
            self.viewModel = viewModel
            self._selectedAnnotation = selectedAnnotation
        }

        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            guard let mapView = gesture.view as? MKMapView else {
                print("Failed to get MKMapView from gesture")
                return
            }

            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            viewModel.addAnnotation(at: coordinate)
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotationID = view.annotation?.title,
                  let selected = viewModel.annotations.first(where: { $0.id.uuidString == annotationID }) else {
                return
            }

            selectedAnnotation = selected
        }
    }
}
