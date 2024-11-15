//
//  TourCardView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/15.
//

import SwiftUI

struct TouristCardView: View {
    @ObservedObject var placesManager: PlacesAPIManager
    @Binding var latitude: Double?
    @Binding var longitude: Double?

    var body: some View {
        VStack {
            if placesManager.isLoading {
               Text("ローディング")
            } else if placesManager.nearbyPlaces.isEmpty {
                MessageView(message: "No nearby tourist spots found.")
            } else {
                TouristPlacesTabView(places: placesManager.nearbyPlaces)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            updatePlacesIfNeeded()
        }
        .onChange(of: latitude) {
            updatePlaces()
        }
        .onChange(of: longitude) {
            updatePlaces()
        }
    }

    private func updatePlacesIfNeeded() {
        if placesManager.nearbyPlaces.isEmpty {
            updatePlaces()
        }
    }

    private func updatePlaces() {
        if let lat = latitude, let lon = longitude {
            Task {
                await placesManager.fetchNearbyPlaces(latitude: lat, longitude: lon)
            }
        }
    }
}


struct MessageView: View {
    let message: String

    var body: some View {
        Text(message)
    }
}

struct TouristPlacesTabView: View {
    let places: [Place]

    var body: some View {
        TabView {
            ForEach(places) { place in
                TouristCard(place: place)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}

