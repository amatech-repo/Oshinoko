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

struct HomeModalView: View {
    let pin: Pin
    let onEdit: () -> Void

    var body: some View {
        VStack {
            Text("ピン情報")
                .font(.headline)
            Text("タイトル: \(pin.metadata.title ?? "不明")")
            Text("説明: \(pin.metadata.description ?? "なし")")
            Spacer()
            Button("編集") {
                onEdit()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}


extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct PinDetailView: View {
    let pin: Pin
    @StateObject private var chatViewModel: ChatViewModel

    init(pin: Pin) {
        self.pin = pin
        // チャット用 ViewModel を初期化（ピンの ID に基づく）
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(pinID: pin.id ?? ""))
    }

    var body: some View {
        VStack {
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

            // チャットビューの表示
            ChatView(viewModel: chatViewModel, currentUserID: "User123")
        }
        .navigationTitle("ピン詳細")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }
}
