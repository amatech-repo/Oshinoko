import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var mapView: MKMapView
    var viewModel: MapViewModel

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator

        // 長押しジェスチャーを追加
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations) // 古い注釈を削除
        let annotations = viewModel.annotations.map { annotation in
            let pin = MKPointAnnotation()
            pin.coordinate = annotation.coordinate
            return pin
        }
        uiView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var viewModel: MapViewModel

        init(_ parent: MapView, viewModel: MapViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }

        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            let location = gesture.location(in: parent.mapView)
            let coordinate = parent.mapView.convert(location, toCoordinateFrom: parent.mapView)
            viewModel.addAnnotation(at: coordinate)
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // ピンが選択されたときの処理（必要に応じて）
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            // 必要なら更新時の処理
        }
    }
}


struct MapUIKitView: UIViewRepresentable {
    @Binding var mapView: MKMapView
    var viewModel: MapViewModel

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations) // 古い注釈を削除
        let annotations = viewModel.annotations.map { annotation in
            let pin = MKPointAnnotation()
            pin.coordinate = annotation.coordinate
            return pin
        }
        uiView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapUIKitView
        var viewModel: MapViewModel

        init(_ parent: MapUIKitView, viewModel: MapViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // ピンが選択されたときの処理（必要に応じて）
        }

        func mapView(_ mapView: MKMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
            viewModel.addAnnotation(at: coordinate)
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            // 必要なら更新時の処理
        }
    }
}

