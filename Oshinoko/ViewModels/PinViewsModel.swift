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
    @Published var pins: [Pin] = [] // すべてのピン情報
    @Published var messages: [ChatMessage] = [] // 選択中のピンのチャットメッセージ
    @Published var currentRoute: MKRoute? = nil
    @Published var isRouteDisplayed: Bool = false
    @Published var currentLocation: CLLocationCoordinate2D? = nil // 現在地を格納

        private var locationManager = LocationManager()

    private let db = Firestore.firestore()


    init() {
            // LocationManager の現在地を監視
            locationManager.$currentLocation
                .assign(to: &$currentLocation)
        }

    // ピンを取得
    func fetchPins() async {
        do {
            let snapshot = try await db.collection("pins").getDocuments()
            self.pins = snapshot.documents.compactMap { try? $0.data(as: Pin.self) }
        } catch {
            print("ピンの取得エラー: \(error.localizedDescription)")
        }
    }

    func calculateRoute(to destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
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

    // ピンに関連するチャットメッセージを取得
    func fetchMessages(for pinID: String) async {
        do {
            let snapshot = try await db.collection("pins").document(pinID).collection("chats").order(by: "timestamp").getDocuments()
            self.messages = snapshot.documents.compactMap { try? $0.data(as: ChatMessage.self) }
        } catch {
            print("チャットメッセージの取得エラー: \(error.localizedDescription)")
        }
    }

    // 新しいピンを追加
    func addPin(coordinate: Coordinate, metadata: Metadata) async throws {
        let pin = Pin(coordinate: coordinate, metadata: metadata)
        pins.append(pin)

        print("Pin added to ViewModel: \(pin)")

        do {
            // Firestoreへの書き込みが非同期なので`await`が必要
            try await db.collection("pins").addDocument(from: pin)
        } catch {
            print("Firestore error: \(error.localizedDescription)")
            throw error
        }
    }

    // チャットメッセージを追加
    func addMessage(to pinID: String, message: ChatMessage) async {
        do {
            try await db.collection("pins").document(pinID).collection("chats").addDocument(from: message)
        } catch {
            print("メッセージの追加エラー: \(error.localizedDescription)")
        }
    }
}
