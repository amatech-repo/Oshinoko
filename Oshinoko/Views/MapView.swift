
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        // 長押しジェスチャーを追加
        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handleLongPress(_:))
        )
        mapView.addGestureRecognizer(longPressGesture)

        // 初期範囲を設定
        mapView.setRegion(viewModel.region, animated: true)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)

        // アノテーションを追加
        let pins = viewModel.annotations.map { annotation -> MKPointAnnotation in
            let pin = MKPointAnnotation()
            pin.coordinate = annotation.coordinate
            return pin
        }

        uiView.addAnnotations(pins)

        // デバッグ用ログ
        print("Updating MapView with annotations: \(pins.map { $0.coordinate })")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var viewModel: MapViewModel

        init(viewModel: MapViewModel) {
            self.viewModel = viewModel
        }

        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            guard let mapView = gesture.view as? MKMapView else {
                print("Failed to get MKMapView from gesture")
                return
            }

            // タップ位置を座標に変換
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

            // デバッグ用ログ
            print("Long press detected at coordinate: \(coordinate)")

            // ViewModelにアノテーションを追加
            viewModel.addAnnotation(at: coordinate)
        }
    }
}
