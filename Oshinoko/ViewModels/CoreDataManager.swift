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

    // 座標と住所を保存
    func saveBookmark(
        id: String,
        latitude: Double,
        longitude: Double,
        address: String?,
        title: String?,
        description: String?
    ) {
        let bookmark = Bookmark(context: context)
        bookmark.id = id
        bookmark.latitude = latitude
        bookmark.longitude = longitude
        bookmark.address = address


        saveContext()
    }

    // 保存したブックマークを取得
    func fetchBookmarks() -> [Bookmark] {
        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        do {
            return try context.fetch(request)
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
