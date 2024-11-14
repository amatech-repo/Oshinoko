//
//  PinViewsModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import Foundation
import FirebaseFirestore

@MainActor
class PinsViewModel: ObservableObject {
    @Published var pins: [Pin] = [] // すべてのピン情報
    @Published var messages: [ChatMessage] = [] // 選択中のピンのチャットメッセージ

    private let db = Firestore.firestore()

    // ピンを取得
    func fetchPins() async {
        do {
            let snapshot = try await db.collection("pins").getDocuments()
            self.pins = snapshot.documents.compactMap { try? $0.data(as: Pin.self) }
        } catch {
            print("ピンの取得エラー: \(error.localizedDescription)")
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
    func addPin(coordinate: Coordinate, metadata: Metadata) async {
        let pin = Pin(coordinate: coordinate, metadata: metadata)
        do {
            try db.collection("pins").addDocument(from: pin)
        } catch {
            print("ピンの追加エラー: \(error.localizedDescription)")
        }
    }

    // チャットメッセージを追加
    func addMessage(to pinID: String, message: ChatMessage) async {
        do {
            try db.collection("pins").document(pinID).collection("chats").addDocument(from: message)
        } catch {
            print("メッセージの追加エラー: \(error.localizedDescription)")
        }
    }
}
