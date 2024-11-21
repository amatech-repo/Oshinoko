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
            VStack {
                CustomText(text: "詳細情報", font: .headline)
                CustomTextField(placeholder: "タイトル", text: $title)
                CustomTextField(placeholder: "説明", text: $description)
            }
            .padding()
            .glassmorphismBackground(colors: [
                Color(hex: "91DDCF"),
                Color(hex: "E8C5E5"),
                Color(hex: "F19ED2")
            ])
            .navigationTitle("ピン情報を入力")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        // 必要ならロジックを追加
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
                    .disabled(title.isEmpty || description.isEmpty) // バリデーション
                }
            }
        }
    }
}
