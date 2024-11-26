//
//  CoreDataManager.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/19.
//

import SwiftUI
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager() // シングルトンクラス

    private let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "BookmarksDataModel") // CoreDataモデル名
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreDataのロードエラー: \(error.localizedDescription)")
            }
        }
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func saveBookmark(
        id: String,
        latitude: Double,
        longitude: Double,
        address: String?,
        cityName: String?,
        subLocality: String?, // 新しく追加
        title: String?,
        description: String?
    ) {
        let bookmark = Bookmark(context: context)
        bookmark.id = id
        bookmark.latitude = latitude
        bookmark.longitude = longitude
        bookmark.address = address
        bookmark.cityName = cityName
        bookmark.subLocality = subLocality // 保存

        // デバッグ: 保存値を確認
        print("Saving Bookmark:")
        print("ID: \(id), Latitude: \(latitude), Longitude: \(longitude)")
        print("Address: \(address ?? "nil"), City: \(cityName ?? "nil"), SubLocality: \(subLocality ?? "nil")")

        saveContext()
    }




    func fetchBookmarks() -> [Bookmark] {
        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        do {
            let bookmarks = try context.fetch(request)
            bookmarks.forEach { bookmark in
                print("フェッチされたデータ:")
                print("Address: \(bookmark.address ?? "nil"), City: \(bookmark.cityName ?? "nil"), SubLocality: \(bookmark.subLocality ?? "nil")")
            }
            return bookmarks
        } catch {
            print("ブックマーク取得エラー: \(error.localizedDescription)")
            return []
        }
    }


    // ブックマークを削除
    func deleteBookmark(bookmark: Bookmark) {
        context.delete(bookmark)
        saveContext()
    }

    // コンテキストを保存
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("コンテキスト保存エラー: \(error.localizedDescription)")
            }
        }
    }
}
