//
//  TourCardModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/15.
//

import Foundation

struct PlacesResponse: Codable {
    let results: [Place]
}

struct Place: Codable, Identifiable {
    let id: String
    let name: String
    let vicinity: String
    let rating: Double?
    let geometry: Geometry?
    let photos: [Photo]?

    // `Identifiable`に準拠するためのID
    enum CodingKeys: String, CodingKey {
        case id = "place_id"
        case name
        case vicinity
        case rating
        case geometry
        case photos
    }

    // 画像の参照を取り出すための計算プロパティ
    var photoReference: String? {
        photos?.first?.photoReference
    }
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct Photo: Codable {
    let photoReference: String

    enum CodingKeys: String, CodingKey {
        case photoReference = "photo_reference"
    }
}

struct OpeningHours: Codable {
    let openNow: Bool?

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
    }
}
