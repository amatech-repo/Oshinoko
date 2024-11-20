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
        List(bookmarks, id: \.self) { bookmark in
            BookmarkRow(bookmark: bookmark)
        }
        .onAppear {
            bookmarks = CoreDataManager.shared.fetchBookmarks()
        }
        .background(Color(.systemBackground))
    }
}

// BookmarkRow for displaying individual bookmarks
struct BookmarkRow: View {
    let bookmark: Bookmark

    var body: some View {
        VStack(alignment: .leading) {
            Text(bookmark.address ?? "No Address")
            Text("Coordinates: \(bookmark.latitude), \(bookmark.longitude)")
                .font(.caption)
        }
    }
}
