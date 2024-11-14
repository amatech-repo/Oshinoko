import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel: MapViewModel
    @State private var showModal = false // モーダル表示状態
    @State private var selectedPinID: String? // 選択されたピンID

    init(destination: CLLocationCoordinate2D) {
        _viewModel = StateObject(wrappedValue: MapViewModel(destination: destination))
    }

    var body: some View {
        ZStack {
            Map(
                coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: viewModel.annotations
            ) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Button(action: {
                        viewModel.selectedAnnotation = item
                        showModal = true
                        // サンプルのピンID（Firestoreに実際に保存されたIDに変更）
                        selectedPinID = "samplePinID"
                    }) {
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(item.color)
                    }
                }
            }
            .onAppear {
                viewModel.fetchUserLocation()
            }
        }
        .sheet(isPresented: $showModal) {
            if let pinID = selectedPinID {
                ChatView(pinID: pinID, currentUserID: "currentUserID")
            }
        }
    }
}
