import UIKit

/// Одна коллекция, две секции — как на макете: весь экран скроллится по вертикали,
/// а оранжевая секция (пользователи) внутри себя скроллится по горизонтали.
/// Это заменяет две отдельные коллекции и ручное схлопывание секции через констрейнт.
enum FeedLayoutFactory {

    static func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch FeedSection(rawValue: sectionIndex) {
            case .users: return usersSection()
            case .posts, .none: return postsSection()
            }
        }
    }

    // MARK: - Sections

    private static func usersSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )

        // Высота estimated: ячейка растёт вместе с Dynamic Type.
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(220),
                heightDimension: .estimated(110)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = Theme.itemSpacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: Theme.inset, bottom: Theme.inset, trailing: Theme.inset
        )
        section.boundarySupplementaryItems = [makeHeader()]
        return section
    }

    private static func postsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(140)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(140)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Theme.itemSpacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Theme.spacing, leading: Theme.inset, bottom: 24, trailing: Theme.inset
        )
        section.boundarySupplementaryItems = [makeHeader()]
        return section
    }

    private static func makeHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(44)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}
