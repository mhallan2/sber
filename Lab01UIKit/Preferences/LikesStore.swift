import Foundation

protocol LikesStoring: AnyObject {
    func isLiked(_ postID: Int) -> Bool
    func toggle(_ postID: Int)
}

/// Лайки не кэшируются в памяти: источник правды — хранилище,
/// поэтому после `SessionCleaner` устаревших данных не остаётся.
final class LikesStore: LikesStoring {

    private let store: KeyValueStore

    init(store: KeyValueStore) {
        self.store = store
    }

    func isLiked(_ postID: Int) -> Bool {
        likedIDs.contains(postID)
    }

    func toggle(_ postID: Int) {
        var ids = likedIDs
        if !ids.insert(postID).inserted {
            ids.remove(postID)
        }
        store.setValue(Array(ids), forKey: .likedPostIds)
    }

    private var likedIDs: Set<Int> {
        let stored: [Int]? = store.value(forKey: .likedPostIds)
        return Set(stored ?? [])
    }
}
