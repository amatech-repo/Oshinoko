//
//  TouristCard.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/15.
//

import SwiftUI
import WebKit

struct TouristCard: View {

    let place: Place
    var body: some View {
        NavigationLink(destination: PlaceSearchWebView(query: place.name)) {
            VStack(alignment: .leading, spacing: 8) {
                PlaceImageView(photoReference: place.photoReference)
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .foregroundColor(.white)

                    Text(place.vicinity)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)

                    if let rating = place.rating {
                        RatingView(rating: rating)
                    }
                }
                .padding([.horizontal, .bottom])
            }
            .frame(width: UIScreen.main.bounds.width * 0.85)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RatingView: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<Int(rating.rounded()), id: \.self) { _ in
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
            Text(String(format: "%.1f", rating))
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct PlaceSearchWebView: UIViewRepresentable {
    let query: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()

        if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let urlString = "https://www.google.com/search?q=\(encodedQuery)"
            if let url = URL(string: urlString) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
