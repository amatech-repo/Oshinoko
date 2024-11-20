//
//  ModalView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI
import MapKit

struct PinDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let pin: Pin

    @ObservedObject private var pinsViewModel: PinsViewModel
    @State private var isRouteDisplayed: Bool = false
    @State private var currentRoute: MKRoute? = nil
    @StateObject private var placesManager = PlacesAPIManager()
    @State private var latitude: Double?
    @State private var longitude: Double?
    @StateObject private var chatViewModel: ChatViewModel
    @State private var prefectureName: String? = nil
    @State private var cityName: String? = nil
    @State private var subLocalityName: String? = nil
    @State private var prefecturalCapital: String? = nil
    @StateObject private var geocodingManager = GeocodingManager()

    init(pin: Pin, pinsViewModel: PinsViewModel) {
        self.pin = pin
        self.pinsViewModel = pinsViewModel
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(pinID: pin.wrappedID))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                pinDetailsSection
                addressSection
                Divider()
                mapSection
                Divider()
                chatSection
                actionButtons
            }
            .padding()
        }
        .onAppear {
            setupData()
        }
        .navigationTitle("ピン詳細")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }

    // MARK: - Section Views

    private var pinDetailsSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("タイトル: \(pin.metadata.title)")
            Text("説明: \(pin.metadata.description)")
        }
    }

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let prefecture = prefectureName, let city = cityName {
                if let subLocality = subLocalityName {
                    Text("住所: \(prefecture) \(city) \(subLocality)")
                } else {
                    Text("住所: \(prefecture) \(city)")
                }
            } else {
                Text("住所を取得中...").foregroundColor(.gray)
            }

            if let capital = prefecturalCapital {
                Text("県庁所在地: \(capital)")
            }
        }
    }

    private var mapSection: some View {
        Group {
            if let latitude = latitude, let longitude = longitude {
                TouristCardView(
                    placesManager: placesManager,
                    latitude: Binding.constant(latitude),
                    longitude: Binding.constant(longitude)
                )
                .frame(height: 300)
            } else {
                Text("位置情報が利用できません").foregroundColor(.gray)
            }
        }
    }

    private var chatSection: some View {
        ChatView(
            viewModel: chatViewModel,
            currentUserID: authViewModel.userID ?? "",
            currentUserName: authViewModel.name,
            currentUserIcon: authViewModel.icon
        )
        .onAppear {
            chatViewModel.startListeningForMessages()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button("ブックマーク") {
                saveBookmark()
            }
            .padding()

            Button("行く") {
                calculateRoute()
            }
            .disabled(isRouteDisplayed)
            .padding()

            if isRouteDisplayed {
                Button("キャンセル") {
                    cancelRoute()
                }
            }
        }
    }

    // MARK: - Helpers

    private func setupData() {
        latitude = pin.coordinate.latitude
        longitude = pin.coordinate.longitude

        geocodingManager.getAddressDetails(for: pin.coordinate.toCLLocationCoordinate2D()) { prefecture, city, subLocality in
            self.prefectureName = prefecture
            self.cityName = city
            self.subLocalityName = subLocality
        }
    }

    private func saveBookmark() {
        if let latitude = latitude, let longitude = longitude {
            CoreDataManager.shared.saveBookmark(
                id: pin.id ?? "idがないよ",
                latitude: latitude,
                longitude: longitude,
                address: prefectureName ?? "住所不明",
                title: pin.metadata.title,
                description: pin.metadata.description
            )
            print("ブックマークを保存しました")
        } else {
            print("座標が取得できません")
        }
    }

    private func calculateRoute() {
        if let latitude = latitude, let longitude = longitude {
            pinsViewModel.calculateRoute(to: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
    }

    private func cancelRoute() {
        pinsViewModel.isRouteDisplayed = false
        pinsViewModel.currentRoute = nil
    }
}



extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
