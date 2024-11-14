//
//  MapAnotationItem.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import Foundation
import MapKit

struct MapAnnotationItem: Identifiable {
    let id = UUID()  // 一意の識別子
    var coordinate: CLLocationCoordinate2D  // ピンを置く場所
}
