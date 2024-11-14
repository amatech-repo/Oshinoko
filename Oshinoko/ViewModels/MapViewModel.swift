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

    private let db = Firestore.firestore()

    init() {
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917),
            span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
        )
    }

    func fetchPins() async {
        do {
            let snapshot = try await db.collection("pins").getDocuments()
            self.pins = snapshot.documents.compactMap { try? $0.data(as: Pin.self) }
            self.annotations = pins.map { pin in
                MapAnnotationItem(coordinate: pin.coordinate.toCLLocationCoordinate2D(), color: .green)
            }
        } catch {
            print("ピンの取得エラー: \(error.localizedDescription)")
        }
    }

    func onPinTapped(annotation: MapAnnotationItem) {
        guard let pin = pins.first(where: { areCoordinatesEqual($0.coordinate.toCLLocationCoordinate2D(), annotation.coordinate) }) else {
            print("Error: Pin data not found for tapped annotation")
            return
        }
        guard let pinID = pin.id else {
            print("Error: Pin ID is nil")
            return
        }

        Task {
            await fetchMessages(for: pinID)
        }
    }

    func areCoordinatesEqual(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    func fetchMessages(for pinID: String) async {
        do {
            let snapshot = try await db.collection("pins").document(pinID).collection("chats").order(by: "timestamp").getDocuments()
            self.messages = snapshot.documents.compactMap { try? $0.data(as: ChatMessage.self) }
        } catch {
            print("チャットメッセージの取得エラー: \(error.localizedDescription)")
        }
    }

    func addPin(coordinate: CLLocationCoordinate2D, metadata: Metadata) async {
        let newPin = Pin(
            id: nil,
            coordinate: Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude),
            metadata: metadata
        )

        do {
            try await addPinToFirestore(pin: newPin)
            await fetchPins() // 再取得して更新
        } catch {
            print("Failed to add pin: \(error.localizedDescription)")
        }
    }

    private func addPinToFirestore(pin: Pin) async throws {
        let pinData = try Firestore.Encoder().encode(pin)

        do {
            let _ = try await db.collection("pins").addDocument(data: pinData)
        } catch {
            throw error
        }
    }
}

extension Coordinate {
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
