//
//  BookmarksTab.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/20.
//

import SwiftUI

struct BookmarksTab: View {
    @Binding var bookmarks: [Bookmark]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(bookmarks, id: \.self) { bookmark in
                    BookmarkRow(bookmark: bookmark)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.6)) // 白色の透明感
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .glassmorphismBackground(colors: [Color(hex: "91DDCF"), Color(hex: "F19ED2")])
        .onAppear {
            bookmarks = CoreDataManager.shared.fetchBookmarks()
        }
    }
}

struct BookmarkRow: View {
    let bookmark: Bookmark

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(bookmark.cityName ?? "No City")
                    .onAppear {
                        print("City in Row: \(bookmark.cityName ?? "nil")")
                    }
                Text(bookmark.address ?? "No Address")
                    .onAppear {
                        print("Address in Row: \(bookmark.address ?? "nil")")
                    }
            }
            if let subLocality = bookmark.subLocality { // 町名や地区名が存在する場合のみ表示
                Text(subLocality)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .onAppear {
                        print("SubLocality in Row: \(subLocality)")
                    }
            }
            Text("Coordinates: \(bookmark.latitude), \(bookmark.longitude)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

