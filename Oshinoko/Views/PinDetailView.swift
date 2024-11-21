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
    @Environment(\.presentationMode) private var presentationMode
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
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    pinDetailsSection
                        .glassmorphismSection()

                    addressSection
                        .glassmorphismSection()

                    mapSection
                        .glassmorphismSection()

                    chatSection
                        .glassmorphismSection()

                    actionButtons
                }
                .padding()
            }
            .onAppear {
                setupData()
            }
            .glassmorphismBackground(colors: [
                Color(hex: "91DDCF"),
                Color(hex: "E8C5E5"),
                Color(hex: "F19ED2")
            ])
            .navigationTitle("ピン詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        cancelAllActions()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Section Views

    private var pinDetailsSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            CustomText(text: "タイトル: \(pin.metadata.title)", font: .headline,foregroundColor: .gray)
            CustomText(text: "説明: \(pin.metadata.description)", font: .subheadline, foregroundColor: .gray)

        }
    }

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let prefecture = prefectureName, let city = cityName {
                if let subLocality = subLocalityName {
                    CustomText(text: "住所: \(prefecture) \(city) \(subLocality)", font: .headline, foregroundColor: .gray)
                } else {
                    CustomText(text: "住所: \(prefecture) \(city)")
                }
            } else {
                CustomText(text: "住所を取得中...", foregroundColor: .gray)
            }

            if let capital = prefecturalCapital {
                CustomText(text: "県庁所在地: \(capital)", font: .subheadline, foregroundColor: .gray)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
                Text("位置情報が利用できません")
                    .foregroundColor(.gray)
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
            CustomButton(
                title: "ブックマーク",
                action: saveBookmark,
                backgroundColor: Color(hex: "91DDCF"),
                opacity: 0.7
            )

            CustomButton(
                title: "行く",
                action: calculateRoute,
                backgroundColor: Color(hex: "E8C5E5"),
                opacity: 0.7
            )
            .disabled(isRouteDisplayed)

            if isRouteDisplayed {
                CustomButton(
                    title: "経路解除",
                    action: cancelRoute,
                    backgroundColor: Color(hex: "F19ED2"),
                    opacity: 0.7
                )
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
            isRouteDisplayed = true
        }
    }

    private func cancelRoute() {
        pinsViewModel.isRouteDisplayed = false
        pinsViewModel.currentRoute = nil
        isRouteDisplayed = false
    }

    private func cancelAllActions() {
        cancelRoute()
    }
}



// MARK: - Glassmorphism Section Modifier
extension View {
    func glassmorphismSection() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.6))
                    .shadow(radius: 5)
            )
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
