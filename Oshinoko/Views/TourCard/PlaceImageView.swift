//
//  PlaceImageView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/15.
//

import SwiftUI

struct PlaceImageView: View {
    let photoReference: String?
    
    var body: some View {
        if let photoReference = photoReference {
            let photoURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=\(photoReference)&key=AIzaSyBybc9S1ppDKOpjTioOKxSaiq-E56y6xmY"
            
            AsyncImage(url: URL(string: photoURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .cornerRadius(20)
                        .clipped()
                case .failure:
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text("画像を取得できませんでした")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 250)
                    .background(Color.gray)
                    .cornerRadius(20)
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Color.gray
                .frame(maxWidth: .infinity, maxHeight: 250)
                .cornerRadius(20)
                .overlay(
                    Text("画像なし")
                        .foregroundColor(.white)
                        .font(.caption)
                )
        }
    }
}

