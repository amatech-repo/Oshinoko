//
//  HomeView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @State private var selectedPin: Pin?
    @StateObject private var pinsViewModel = PinsViewModel()

    var body: some View {
        ZStack {
            MapView(
                pinsViewModel: pinsViewModel,
                selectedPin: $selectedPin
            )
            .onAppear {
                Task {
                    await pinsViewModel.fetchPins()
                }
            }
            .sheet(item: $selectedPin) { pin in
                ChatView(
                    pinID: pin.wrappedID,
                    currentUserID: "User123"
                )
            }
        }
    }
}
