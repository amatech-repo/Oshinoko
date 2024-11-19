//
//  PinViewsModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import Foundation
import FirebaseFirestore
import MapKit

@MainActor
class PinsViewModel: ObservableObject {
    @Published var pins: [Pin] = [] // 全てのピン情報
    @Published var messages: [ChatMessage] = [] // 選択中のピンのチャットメッセージ
    @Published var currentRoute: MKRoute? = nil
    @Published var isRouteDisplayed: Bool = false
    @Published var currentLocation: CLLocationCoordinate2D? = nil // 現在地を格納
    @Published var chatViewModels: [String: ChatViewModel] = [:] // 各ピンごとのチャットモデル
    private let authViewModel: AuthViewModel


    private var locationManager = LocationManager()
    private var currentDirections: MKDirections? // 現在の経路計算インスタンス
    private let db = Firestore.firestore()

    init(authViewModel: AuthViewModel) {
            self.authViewModel = authViewModel // AuthViewModel を外部から注入
            // LocationManager の現在地を監視
            locationManager.$currentLocation
                .assign(to: &$currentLocation)
        }

    // ChatViewModel を取得または生成
        func getChatViewModel(for pinID: String) -> ChatViewModel {
            if let viewModel = chatViewModels[pinID] {
                return viewModel
            } else {
                let newViewModel = ChatViewModel(pinID: pinID)
                chatViewModels[pinID] = newViewModel
                return newViewModel
            }
        }

    // ピンを取得
    func fetchPins() async {
        do {
            let snapshot = try await db.collection("pins").getDocuments()
            pins = snapshot.documents.compactMap { try? $0.data(as: Pin.self) }
        } catch {
            print("ピンの取得エラー: \(error.localizedDescription)")
        }
    }

    // 経路計算
    func calculateRoute(to destination: CLLocationCoordinate2D) {
        currentDirections?.cancel() // 前回の計算をキャンセル
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        self.currentDirections = directions

        directions.calculate { [weak self] response, error in
            if let error = error {
                print("経路計算エラー: \(error.localizedDescription)")
                return
            }

            guard let route = response?.routes.first else { return }
            DispatchQueue.main.async {
                self?.currentRoute = route
                self?.isRouteDisplayed = true
            }
        }
    }

    // 経路表示をクリア
    func clearRoute() {
        isRouteDisplayed = false
        currentRoute = nil
        currentDirections?.cancel()
    }

    // ピンに関連するチャットメッセージを取得
    func fetchMessages(for pinID: String) async {
        do {
            let snapshot = try await db.collection("pins").document(pinID).collection("chats").order(by: "timestamp").getDocuments()
            messages = snapshot.documents.compactMap { try? $0.data(as: ChatMessage.self) }
        } catch {
            print("チャットメッセージの取得エラー: \(error.localizedDescription)")
        }
    }

    func addPin(coordinate: Coordinate, metadata: Metadata) async {
            guard let userIconURL = authViewModel.icon else {
                print("ユーザーアイコンが見つかりません")
                return
            }
            let pin = Pin(
                id: UUID().uuidString,
                coordinate: coordinate,
                metadata: metadata,
                iconURL: userIconURL // AuthViewModel から取得
            )
            do {
                try await savePinToFirestore(pin: pin)
                pins.append(pin)
            } catch {
                print("Firestoreエラー: \(error.localizedDescription)")
            }
        }

    private func savePinToFirestore(pin: Pin) async throws {
        let pinData = try Firestore.Encoder().encode(pin)
        try await db.collection("pins").addDocument(data: pinData)
    }

    // 座標の比較 (許容範囲)
    func areCoordinatesEqual(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D, tolerance: Double = 0.0001) -> Bool {
        return abs(lhs.latitude - rhs.latitude) < tolerance && abs(lhs.longitude - rhs.longitude) < tolerance
    }


}


