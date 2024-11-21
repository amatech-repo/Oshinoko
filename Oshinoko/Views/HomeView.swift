//
//  HomeView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI
import MapKit

struct HomeView: View {
    // MARK: - State Properties
    @State private var selectedPin: Pin?
    @State private var newPinCoordinate: CLLocationCoordinate2D?
    @State private var isShowingInformationModal = false
    @State private var selection = 1
    @State private var bookmarks: [Bookmark] = []

    // MARK: - Observed ViewModels
    @StateObject private var chatViewModel = ChatViewModel(pinID: "")
    @ObservedObject var pinsViewModel: PinsViewModel

    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()

            TabView(selection: $selection) {
                mapTab
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                    .tag(1)

                ChatTab(viewModel: chatViewModel, currentUserID: "12345", currentUserName: "Erika Sakurai", currentUserIcon: nil)
                    .tabItem {
                        Label("AI", systemImage: "message")
                    }
                    .tag(2)

                BookmarksTab(bookmarks: $bookmarks) // Refactored to a separate component
                    .tabItem {
                        Label("Bookmark", systemImage: "person")
                    }
                    .tag(3)
            }
        }
        .glassmorphismBackground(
            colors: [Color(hex: "91DDCF"), Color(hex: "E8C5E5")]
        )
    }

    // MARK: - Tab 1: Map Tab
    private var mapTab: some View {
        VStack(spacing: 0) {
            MapView(
                pinsViewModel: pinsViewModel,
                selectedPin: $selectedPin,
                newPinCoordinate: $newPinCoordinate,
                isShowingModal: $isShowingInformationModal,
                onLongPress: { coordinate in
                    newPinCoordinate = coordinate
                    isShowingInformationModal = true
                }
            )
            .frame(maxWidth: .infinity, maxHeight: 720)
            .onAppear {
                Task {
                    await pinsViewModel.fetchPins()
                }
            }
            Spacer()
        }
        .sheet(isPresented: $isShowingInformationModal) {
            if let coordinate = newPinCoordinate {
                InformationModal(
                    coordinate: coordinate,
                    onSave: { metadata in
                        Task {
                            await pinsViewModel.addPin(
                                coordinate: Coordinate(
                                    latitude: coordinate.latitude,
                                    longitude: coordinate.longitude
                                ),
                                metadata: metadata
                            )
                        }
                        resetModalState()
                    }
                )
            }
        }
        .sheet(item: $selectedPin) { pin in
            PinDetailView(pin: pin, pinsViewModel: pinsViewModel)
        }
        .glassmorphismBackground(
            colors: [Color(hex: "91DDCF"), Color(hex: "E8C5E5")]
        )
    }

    private func resetModalState() {
        newPinCoordinate = nil
        isShowingInformationModal = false
    }
}
