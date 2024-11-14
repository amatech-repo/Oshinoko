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
        // アノテーションを再描画
        uiView.removeAnnotations(uiView.annotations)

        let annotations = viewModel.annotations.map { annotation in
            let pin = MKPointAnnotation()
            pin.coordinate = annotation.coordinate
            return pin
        }

        uiView.addAnnotations(annotations)
        print("Annotations added: \(annotations)") // デバッグログ
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
            print("Long press detected at coordinate: \(coordinate)")

            viewModel.addAnnotation(at: coordinate) // アノテーションをViewModelに追加
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // ピンが選択された時の処理（必要に応じて）
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            // 地図の移動やズーム後の処理（必要に応じて）
        }
    }
}
