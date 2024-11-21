import Foundation
import SwiftUI
import MapKit
import FirebaseFirestore

@MainActor
class PinsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )
    @Published var pins: [Pin] = []
    @Published var messages: [ChatMessage] = []
    @Published var isRouteDisplayed = false
    @Published var currentRoute: MKRoute? = nil
    @Published var currentLocation: CLLocationCoordinate2D? = nil
    @Published var chatViewModels: [String: ChatViewModel] = [:]

    // MARK: - Private Properties
    private let db = Firestore.firestore()
    private var locationManager = LocationManager()
    private var currentDirections: MKDirections? = nil
    private let authViewModel: AuthViewModel

    // MARK: - Initializer
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        // Observe current location updates from LocationManager
        locationManager.$currentLocation
            .assign(to: &$currentLocation)
    }

    // MARK: - Pin Management

    /// Fetch pins from Firestore
    func fetchPins() async {
        do {
            let snapshot = try await db.collection("pins").getDocuments()
            self.pins = snapshot.documents.compactMap { try? $0.data(as: Pin.self) }
        } catch {
            print("Error fetching pins: \(error.localizedDescription)")
        }
    }

    /// Add a new pin
    func addPin(coordinate: Coordinate, metadata: Metadata) async {
        // アイコンがない場合はデフォルトを使用
        let userIconURL = fetchUserIcon() ?? "default-icon-url-or-system-image" // デフォルト画像

        let pin = Pin(
            id: UUID().uuidString,
            coordinate: coordinate,
            metadata: metadata,
            iconURL: userIconURL
        )

        do {
            try await savePinToFirestore(pin: pin)
            pins.append(pin)
        } catch {
            print("Error adding pin: \(error.localizedDescription)")
        }
    }

    private func fetchUserIcon() -> String? {
        // アイコンがあれば返す、なければnil
        return authViewModel.icon
    }


    /// Fetch messages for a specific pin
    func fetchMessages(for pinID: String) async {
        do {
            let snapshot = try await db.collection("pins").document(pinID).collection("chats").order(by: "timestamp").getDocuments()
            messages = snapshot.documents.compactMap { try? $0.data(as: ChatMessage.self) }
        } catch {
            print("Error fetching messages: \(error.localizedDescription)")
        }
    }

    /// Retrieve or create a ChatViewModel for a specific pin
    func getChatViewModel(for pinID: String) -> ChatViewModel {
        if let viewModel = chatViewModels[pinID] {
            return viewModel
        } else {
            let newViewModel = ChatViewModel(pinID: pinID)
            chatViewModels[pinID] = newViewModel
            return newViewModel
        }
    }

    // MARK: - Route Management

    /// Calculate a route to the destination coordinate
    func calculateRoute(to destination: CLLocationCoordinate2D) {
        clearRoute()
        let request = createDirectionsRequest(to: destination)
        let directions = MKDirections(request: request)
        self.currentDirections = directions

        directions.calculate { [weak self] response, error in
            if let error = error {
                print("Route calculation error: \(error.localizedDescription)")
                return
            }
            guard let route = response?.routes.first else { return }
            DispatchQueue.main.async {
                self?.currentRoute = route
                self?.isRouteDisplayed = true
            }
        }
    }

    /// Clear the currently displayed route
    func clearRoute() {
        isRouteDisplayed = false
        currentRoute = nil
        currentDirections?.cancel()
    }

    // MARK: - Private Helpers

    /// Save a pin to Firestore
    private func savePinToFirestore(pin: Pin) async throws {
        let pinData = try Firestore.Encoder().encode(pin)
        try await db.collection("pins").addDocument(data: pinData)
    }

    /// Create a directions request
    private func createDirectionsRequest(to destination: CLLocationCoordinate2D) -> MKDirections.Request {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        return request
    }

    // MARK: - Coordinate Comparison

    /// Compare two coordinates with a tolerance
    func areCoordinatesEqual(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D, tolerance: Double = 0.0001) -> Bool {
        return abs(lhs.latitude - rhs.latitude) < tolerance && abs(lhs.longitude - rhs.longitude) < tolerance
    }
}

