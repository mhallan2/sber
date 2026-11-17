import Testing
@testable import Lab01UIKit

@MainActor
struct FeedViewModelTests {

    private func makeViewModel(
        store: InMemoryKeyValueStore = InMemoryKeyValueStore(),
        searchAffectsPosts: Bool = false
    ) -> FeedViewModel {
        FeedViewModel(
            content: TestData.content,
            likes: LikesStore(store: store),
            sortOrderStore: SortOrderStore(store: store),
            searchAffectsPosts: searchAffectsPosts
        )
    }

    @Test func postsAreSortedAscendingByDefault() {
        #expect(makeViewModel().visiblePosts.map(\.id) == [1, 2, 3])
    }

    @Test func toggleSortReversesPostsAndIsPersisted() {
        let store = InMemoryKeyValueStore()
        let viewModel = makeViewModel(store: store)

        viewModel.toggleSortOrder()
        #expect(viewModel.visiblePosts.map(\.id) == [3, 2, 1])

        // «Повторный вход»: новая модель поверх того же хранилища.
        let restored = makeViewModel(store: store)
        #expect(restored.isAscending == false)
        #expect(restored.visiblePosts.map(\.id) == [3, 2, 1])
    }

    @Test func searchFiltersOnlyUsersByDefault() {
        let viewModel = makeViewModel()
        viewModel.updateQuery("bret")

        #expect(viewModel.visibleUsers.map(\.id) == [1])
        #expect(viewModel.visiblePosts.count == 3)
    }

    @Test func searchCanAlsoFilterPosts() {
        let viewModel = makeViewModel(searchAffectsPosts: true)
        viewModel.updateQuery("bret")

        #expect(viewModel.visiblePosts.map(\.id) == [1, 2])
    }

    @Test func likesArePersistedAndNotified() {
        let store = InMemoryKeyValueStore()
        let viewModel = makeViewModel(store: store)

        var notified: [Int] = []
        viewModel.onLikeChange = { notified.append($0) }

        viewModel.toggleLike(2)
        #expect(viewModel.isLiked(2))
        #expect(notified == [2])

        viewModel.toggleLike(2)
        #expect(!viewModel.isLiked(2))
    }

    @Test func unknownAuthorFallback() {
        let viewModel = makeViewModel()
        let orphan = Post(userId: 99, id: 100, title: "", body: "")
        #expect(viewModel.authorName(for: orphan) == L10n.Feed.unknownAuthor)
    }
}
