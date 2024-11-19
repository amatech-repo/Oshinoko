import Foundation
import SwiftUI
import MapKit
import FirebaseFirestore

@MainActor
class MapPinsViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var annotations: [MapAnnotationItem] = []
    @Published var pins: [Pin] = []
    @Published var messages: [ChatMessage] = []
    @Published var isRouteDisplayed: Bool = false
    @Published var currentRoute: MKRoute? = nil
    
    private let db = Firestore.firestore()
    
    init() {
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917),
            span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
        )
    }
    
    func calculateRoute(to destination: CLLocationCoordinate2D) {
        removeRouteOverlay()
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("経路計算エラー: \(error.localizedDescription)")
                return
            }
            
            guard let route = response?.routes.first else { return }
            DispatchQueue.main.async {
                self.currentRoute = route
                self.isRouteDisplayed = true
            }
        }
    }
    
    func removeRouteOverlay() {
        isRouteDisplayed = false
        currentRoute = nil
    }
    
    func fetchPins() async {
        do {
            let snapshot = try await db.collection("pins").getDocuments()
            self.pins = snapshot.documents.compactMap { try? $0.data(as: Pin.self) }
        } catch {
            print("ピンの取得エラー: \(error.localizedDescription)")
        }
    }
    
    func addPin(coordinate: Coordinate, metadata: Metadata) async {
        guard let userIconURL = AuthViewModel.shared.icon else {
            print("ユーザーアイコンがありません")
            return
        }
        
        let pin = Pin(
            id: UUID().uuidString,
            coordinate: coordinate,
            metadata: metadata,
            iconURL: userIconURL
        )
        
        do {
            try await addPinToFirestore(pin: pin)
            pins.append(pin)
        } catch {
            print("Firestoreエラー: \(error.localizedDescription)")
        }
    }
    
    private func addPinToFirestore(pin: Pin) async throws {
        let pinData = try Firestore.Encoder().encode(pin)
        try await db.collection("pins").addDocument(data: pinData)
    }
    
    func fetchMessages(for pinID: String) async {
        do {
            let snapshot = try await db.collection("pins").document(pinID).collection("chats").order(by: "timestamp").getDocuments()
            self.messages = snapshot.documents.compactMap { try? $0.data(as: ChatMessage.self) }
        } catch {
            print("チャットメッセージの取得エラー: \(error.localizedDescription)")
        }
    }
}

