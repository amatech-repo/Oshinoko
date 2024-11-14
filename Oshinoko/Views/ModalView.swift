//
//  ModalView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import Foundation
import SwiftUI

struct AnnotationDetailView: View {
    let annotation: MapAnnotationItem
    let address: String?

    var body: some View {
        VStack {
            Text("注釈の詳細")
                .font(.headline)
            Text("緯度: \(annotation.coordinate.latitude)")
            Text("経度: \(annotation.coordinate.longitude)")
            if let address = address {
                Text("住所: \(address)")
                    .padding()
            } else {
                Text("住所を取得中...")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}
