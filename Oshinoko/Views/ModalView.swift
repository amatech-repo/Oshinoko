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
    @EnvironmentObject var authViewModel: AuthViewModel // AuthViewModelを追加
    let coordinate: CLLocationCoordinate2D
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
                    // キャンセル処理
                },
                trailing: Button("保存") {
                    onSave(Metadata(
                        createdBy: authViewModel.name, // 環境オブジェクトを使用
                        description: description,
                        title: title
                    ))
                }
            )
        }
    }
}



extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct PinDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel // 環境オブジェクトとして authViewModel を追加
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
                Text("タイトル: \(pin.metadata.title)")
                Text("説明: \(pin.metadata.description)")
                
                if let prefecture = prefectureName, let city = cityName {
                    if let subLocality = subLocalityName {
                        Text("住所: \(prefecture) \(city) \(subLocality)")
                    } else {
                        Text("住所: \(prefecture) \(city)")
                    }
                } else {
                    Text("住所を取得中...")
                        .foregroundColor(.gray)
                }
                
                if let capital = prefecturalCapital {
                    Text("県庁所在地: \(capital)")
                }
                
                Divider()
                
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
                
                ChatView(
                    viewModel: chatViewModel,
                    currentUserID: authViewModel.userID ?? "", // @EnvironmentObject を利用
                    currentUserName: authViewModel.name,
                    currentUserIcon: authViewModel.icon
                )
                .onAppear {
                    chatViewModel.startListeningForMessages()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 400)
                
                Button {
                    if let latitude = latitude, let longitude = longitude {
                        pinsViewModel.calculateRoute(to: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    }
                } label: {
                    Text("行く")
                }
                .disabled(pinsViewModel.isRouteDisplayed)
                .padding()
                
                if pinsViewModel.isRouteDisplayed {
                    Button("キャンセル") {
                        pinsViewModel.isRouteDisplayed = false
                        pinsViewModel.currentRoute = nil
                    }
                }
            }
            .padding()
        }
        .onAppear {
            latitude = pin.coordinate.latitude
            longitude = pin.coordinate.longitude
            
            geocodingManager.getAddressDetails(for: pin.coordinate.toCLLocationCoordinate2D()) { prefecture, city, subLocality in
                self.prefectureName = prefecture
                self.cityName = city
                self.subLocalityName = subLocality
            }
        }
        .navigationTitle("ピン詳細")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }
}


