import Foundation
import SwiftUI
import MapKit
import FirebaseFirestore

@MainActor
class MapPinsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )
    @Published var annotations: [MapAnnotationItem] = []
    @Published var pins: [Pin] = []
    @Published var messages: [ChatMessage] = []
    @Published var isRouteDisplayed = false
    @Published var currentRoute: MKRoute? = nil

    // MARK: - Private Properties
    private let db = Firestore.firestore()

    // MARK: - Methods

    /// Calculate route to the given destination coordinate
    func calculateRoute(to destination: CLLocationCoordinate2D) {
        clearRoute()
        let request = createDirectionsRequest(to: destination)
        let directions = MKDirections(request: request)

        directions.calculate { [weak self] response, error in
            if let error = error {
                print("Route calculation error: \(error.localizedDescription)")
                return
            }
            guard let route = response?.routes.first else { return }
            self?.updateRoute(route)
        }
    }

    /// Remove the current route overlay
    func clearRoute() {
        isRouteDisplayed = false
        currentRoute = nil
    }

    /// Fetch pins from Firestore
    func fetchPins() async {
        do {
            let snapshot = try await db.collection("pins").getDocuments()
            self.pins = snapshot.documents.compactMap { try? $0.data(as: Pin.self) }
        } catch {
            print("Error fetching pins: \(error.localizedDescription)")
        }
    }

    /// Add a pin to Firestore and local state
    func addPin(coordinate: Coordinate, metadata: Metadata) async {
        guard let userIconURL = AuthViewModel.shared.icon else {
            print("User icon is missing")
            return
        }

        let pin = Pin(id: UUID().uuidString, coordinate: coordinate, metadata: metadata, iconURL: userIconURL)
        do {
            try await db.collection("pins").addDocument(data: Firestore.Encoder().encode(pin))
            pins.append(pin)
        } catch {
            print("Error adding pin: \(error.localizedDescription)")
        }
    }

    /// Fetch chat messages for a specific pin
    func fetchMessages(for pinID: String) async {
        do {
            let snapshot = try await db.collection("pins").document(pinID).collection("chats").order(by: "timestamp").getDocuments()
            messages = snapshot.documents.compactMap { try? $0.data(as: ChatMessage.self) }
        } catch {
            print("Error fetching messages: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Helpers

    /// Create a directions request
    private func createDirectionsRequest(to destination: CLLocationCoordinate2D) -> MKDirections.Request {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        return request
    }

    /// Update the current route state
    private func updateRoute(_ route: MKRoute) {
        DispatchQueue.main.async {
            self.currentRoute = route
            self.isRouteDisplayed = true
        }
    }
}

