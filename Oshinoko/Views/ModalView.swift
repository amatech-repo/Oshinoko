//
//  ModalView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import Foundation
import SwiftUI
import MapKit

struct InformationModal: View {
    let coordinate: CLLocationCoordinate2D
    let createdBy: String
    let onSave: (Metadata) -> Void

    @State private var title: String = ""
    @State private var description: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("タイトル", text: $title)
                TextField("説明", text: $description)
            }
            .navigationBarTitle("ピン情報を入力", displayMode: .inline)
            .navigationBarItems(
                leading: Button("キャンセル") {
                    // キャンセル処理（必要に応じて追加）
                },
                trailing: Button("保存") {
                    onSave(Metadata(
                        createdBy: createdBy,
                        description: description, title: title
                    ))
                }
            )
        }
    }
}


extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct PinDetailView: View {
    let pin: Pin

    @StateObject private var placesManager = PlacesAPIManager()
    @State private var latitude: Double?
    @State private var longitude: Double?
    @StateObject private var chatViewModel: ChatViewModel

    init(pin: Pin) {
        self.pin = pin
        // チャット用 ViewModel を初期化（ピンの ID に基づく）
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(pinID: pin.id ?? ""))
    }

    var body: some View {
        ScrollView{
            Text("ピン詳細")
                .font(.headline)
                .padding()

            // ピンのメタデータ表示
            VStack(alignment: .leading, spacing: 10) {
                Text("タイトル: \(pin.metadata.title)")
                Text("説明: \(pin.metadata.description)")
            }
            .padding()

            Divider()

            // TouristCardView の表示
            if let latitude = latitude, let longitude = longitude {
                TouristCardView(
                    placesManager: placesManager,
                    latitude: Binding.constant(latitude),
                    longitude: Binding.constant(longitude)
                )
                .frame(height: 300)
            } else {
                Text("位置情報が利用できません")
                    .foregroundColor(.gray)
            }

            // チャットビューの表示
            ChatView(viewModel: chatViewModel, currentUserID: "User123")
                .padding()
        }
        .onAppear {
            // ピンの位置情報を設定
            latitude = pin.coordinate.latitude
            longitude = pin.coordinate.longitude

            // 初回データ取得
            if let lat = latitude, let lon = longitude {

            }
        }
        .navigationTitle("ピン詳細")
        .navigationBarTitleDisplayMode(.inline)
        .padding()

    }
}
