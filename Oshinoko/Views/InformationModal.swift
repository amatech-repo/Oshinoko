//
//  InformationModal.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/20.
//

import Foundation
import SwiftUI
import MapKit

struct InformationModal: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let coordinate: CLLocationCoordinate2D
    let onSave: (Metadata) -> Void

    @State private var title: String = ""
    @State private var description: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("詳細情報")) {
                    TextField("タイトル", text: $title)
                    TextField("説明", text: $description)
                }
            }
            .navigationTitle("ピン情報を入力")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        // 何もしない（必要ならカスタマイズ可能）
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        onSave(Metadata(
                            createdBy: authViewModel.name,
                            description: description,
                            title: title
                        ))
                    }
                    .disabled(title.isEmpty || description.isEmpty) // バリデーション追加
                }
            }
        }
    }
}
