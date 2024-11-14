import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel: MapViewModel
    @State private var mapView = MKMapView() // MKMapViewを利用

    init(destination: CLLocationCoordinate2D) {
        _viewModel = StateObject(wrappedValue: MapViewModel(destination: destination))
    }

    var body: some View {
        ZStack {
            // UIKitベースのMapViewを利用
            MapUIKitView(mapView: $mapView, viewModel: viewModel)

            if let address = viewModel.address {
                Text(address)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            viewModel.fetchUserLocation()
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

