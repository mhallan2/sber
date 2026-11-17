import Foundation

/// Состояние ленты: поиск, сортировка, лайки. Не знает про UIKit.
final class FeedViewModel {

    // MARK: - Outputs

    /// Список пользователей и/или постов изменился.
    var onContentChange: ((_ animated: Bool) -> Void)?
    var onLikeChange: ((Post.ID) -> Void)?
    var onSortOrderChange: ((_ isAscending: Bool) -> Void)?

    private(set) var visibleUsers: [User]
    private(set) var visiblePosts: [Post]

    var isAscending: Bool { sortOrderStore.isAscending }

    // MARK: - Private

    private let users: [User]
    private let posts: [Post]
    private let usersByID: [User.ID: User]
    private let postsByID: [Post.ID: Post]

    private let likes: LikesStoring
    private let sortOrderStore: SortOrderStoring
    private let searchAffectsPosts: Bool
    private var query = ""

    /// - Parameter searchAffectsPosts: по ТЗ поиск фильтрует только оранжевую секцию (`false`).
    ///   Прежняя версия приложения заодно скрывала посты не найденных авторов — включается через `true`.
    init(
        content: FeedContent,
        likes: LikesStoring,
        sortOrderStore: SortOrderStoring,
        searchAffectsPosts: Bool = false
    ) {
        let users = content.users.uniqued(by: \.id)
        let posts = content.posts.uniqued(by: \.id)

        self.users = users
        self.posts = posts
        self.usersByID = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
        self.postsByID = Dictionary(uniqueKeysWithValues: posts.map { ($0.id, $0) })
        self.likes = likes
        self.sortOrderStore = sortOrderStore
        self.searchAffectsPosts = searchAffectsPosts

        self.visibleUsers = users
        self.visiblePosts = Self.sorted(posts, ascending: sortOrderStore.isAscending)
    }

    // MARK: - Lookup (O(1) вместо first(where:) на каждую ячейку)

    func user(id: User.ID) -> User? { usersByID[id] }
    func post(id: Post.ID) -> Post? { postsByID[id] }
    func isLiked(_ postID: Post.ID) -> Bool { likes.isLiked(postID) }

    func authorName(for post: Post) -> String {
        usersByID[post.userId]?.name ?? L10n.Feed.unknownAuthor
    }

    // MARK: - Actions

    func updateQuery(_ newQuery: String) {
        query = newQuery
        recomputeVisibleContent()
        onContentChange?(true)
    }

    func toggleSortOrder() {
        sortOrderStore.isAscending.toggle()
        recomputeVisibleContent()
        onSortOrderChange?(sortOrderStore.isAscending)
        onContentChange?(false)
    }

    func toggleLike(_ postID: Post.ID) {
        likes.toggle(postID)
        onLikeChange?(postID)
    }

    // MARK: - Private

    private func recomputeVisibleContent() {
        visibleUsers = UserSearchFilter.filter(users, query: query)

        let candidates: [Post]
        if searchAffectsPosts, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let matchingIDs = Set(visibleUsers.map(\.id))
            candidates = posts.filter { matchingIDs.contains($0.userId) }
        } else {
            candidates = posts
        }

        visiblePosts = Self.sorted(candidates, ascending: sortOrderStore.isAscending)
    }

    private static func sorted(_ posts: [Post], ascending: Bool) -> [Post] {
        posts.sorted { ascending ? $0.id < $1.id : $0.id > $1.id }
    }
}
