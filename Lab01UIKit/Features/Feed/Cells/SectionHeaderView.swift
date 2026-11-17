import UIKit

final class SectionHeaderView: UICollectionReusableView {

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.accessibilityTraits = .header
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Theme.itemSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.spacing),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.inset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.inset)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String) {
        titleLabel.text = title
    }
}
