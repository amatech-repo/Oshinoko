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

    var body: some View {
        VStack {
            Text("Annotation Details")
                .font(.headline)
            Text("Coordinate: \(annotation.coordinate.latitude), \(annotation.coordinate.longitude)")
            Text("Color: \(annotation.color.description)")
        }
        .padding()
    }
}
