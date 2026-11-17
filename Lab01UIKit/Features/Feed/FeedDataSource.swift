import UIKit

// MARK: - Identifiers

nonisolated enum FeedSection: Int, CaseIterable, Sendable {
    case users
    case posts

    var title: String {
        switch self {
        case .users: return L10n.Feed.usersSection
        case .posts: return L10n.Feed.postsSection
        }
    }
}

/// В снапшоте лежат только идентификаторы; сами модели берутся из `FeedViewModel`.
nonisolated enum FeedItem: Hashable, Sendable {
    case user(User.ID)
    case post(Post.ID)
}

// MARK: - Data source

/// Обёртка над diffable data source: регистрация ячеек, заголовков и снапшоты.
final class FeedDataSource {

    private let dataSource: UICollectionViewDiffableDataSource<FeedSection, FeedItem>

    init(
        collectionView: UICollectionView,
        viewModel: FeedViewModel,
        postCellDelegate: PostCellDelegate
    ) {
        let userRegistration = UICollectionView.CellRegistration<UserCell, User.ID> { cell, _, id in
            guard let user = viewModel.user(id: id) else { return }
            cell.configure(with: user)
        }

        let postRegistration = UICollectionView.CellRegistration<PostCell, Post.ID> { [weak postCellDelegate] cell, _, id in
            guard let post = viewModel.post(id: id) else { return }
            cell.delegate = postCellDelegate
            cell.configure(
                with: post,
                authorName: viewModel.authorName(for: post),
                isLiked: viewModel.isLiked(post.id)
            )
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<SectionHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { header, _, indexPath in
            header.configure(title: FeedSection(rawValue: indexPath.section)?.title ?? "")
        }

        dataSource = UICollectionViewDiffableDataSource<FeedSection, FeedItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .user(let id):
                return collectionView.dequeueConfiguredReusableCell(
                    using: userRegistration, for: indexPath, item: id
                )
            case .post(let id):
                return collectionView.dequeueConfiguredReusableCell(
                    using: postRegistration, for: indexPath, item: id
                )
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }

    /// Обе секции всегда присутствуют в снапшоте: индекс секции в layout совпадает с `FeedSection`.
    func apply(users: [User], posts: [Post], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<FeedSection, FeedItem>()
        snapshot.appendSections(FeedSection.allCases)
        snapshot.appendItems(users.map { .user($0.id) }, toSection: .users)
        snapshot.appendItems(posts.map { .post($0.id) }, toSection: .posts)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func reconfigurePost(id: Post.ID) {
        var snapshot = dataSource.snapshot()
        guard snapshot.itemIdentifiers.contains(.post(id)) else { return }
        snapshot.reconfigureItems([.post(id)])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
