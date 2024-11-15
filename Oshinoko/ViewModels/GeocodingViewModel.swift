//
//  GeocodingViewModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/15.
//

import Foundation
import CoreLocation

class GeocodingManager: ObservableObject {
    private let geocoder = CLGeocoder()

    /// 座標から住所情報を取得
    func getAddressDetails(for coordinate: CLLocationCoordinate2D, completion: @escaping (String?, String?, String?) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil, nil, nil) // エラー時
                return
            }

            let prefecture = placemark.administrativeArea // 都道府県
            let city = placemark.locality // 市町村
            let subLocality = placemark.subLocality // 町名や地区名

            completion(prefecture, city, subLocality)
        }
    }
}
