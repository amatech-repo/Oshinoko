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
        // ユーザーアイコンを確認
        if authViewModel.icon == nil {
            authViewModel.loadIconFromUserDefaults()
        }

        guard let userIconURL = authViewModel.icon, let userID = authViewModel.userID else {
            print("エラー: ユーザー情報（アイコンまたはID）が見つかりません。再ログインしてください。")
            return
        }

        let pinID = UUID().uuidString
        let pin = Pin(
            id: pinID,
            coordinate: coordinate,
            metadata: metadata,
            iconURL: userIconURL // AuthViewModelから取得したURLを利用
        )

        print("⭐️ 新しいPinのデータ: \(pin)") // デバッグ用

        do {
            // FirestoreにPinを保存
            try await savePinToFirestore(pin: pin, userID: userID, userIconURL: userIconURL)

            // ローカルリストに追加
            pins.append(pin)
        } catch {
            print("ピン追加エラー: \(error.localizedDescription)")
        }
    }

    /// FirestoreにPinを保存
    /// FirestoreにPinを保存
    private func savePinToFirestore(pin: Pin, userID: String, userIconURL: String) async throws {
        var pinData = try Firestore.Encoder().encode(pin)

        // ユーザー情報を追加
        pinData["userID"] = userID
        pinData["userIconURL"] = userIconURL

        // Firestoreに保存
        try await db.collection("pins").document(pin.id ?? "無理でした").setData(pinData)
        print("⭐️ Firestoreに保存されたデータ: \(pinData)")
    }


    /// Firestoreから指定されたuserIDのiconURLを取得
    private func fetchIconURL(for userID: String) async throws -> String? {
        let document = try await db.collection("users").document(userID).getDocument()
        let data = document.data()
        return data?["iconURL"] as? String
    }

    /// ピンをFirestoreから取得し、iconURLをマップデータに追加
    func fetchPinsAndUpdateWithIcons() async {
        do {
            // Firestoreからピンデータを取得
            let snapshot = try await db.collection("pins").getDocuments()
            var fetchedPins = snapshot.documents.compactMap { document -> Pin? in
                try? document.data(as: Pin.self)
            }

            // 各ピンのuserIDからiconURLを取得して更新
            // 各ピンのuserIDからiconURLを取得して更新
            for i in 0..<fetchedPins.count {
                var pin = fetchedPins[i] // 配列の要素を一時的にコピー
                let userID = pin.metadata.createdBy
                let iconURL = try await fetchIconURL(for: userID)
                pin.iconURL = iconURL ?? ""
            }

            // マップに反映するピンを更新
            DispatchQueue.main.async {
                self.pins = fetchedPins
            }
        } catch {
            print("ピンまたはアイコンURL取得エラー: \(error.localizedDescription)")
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

