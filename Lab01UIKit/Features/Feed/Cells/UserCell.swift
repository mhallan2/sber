import UIKit

final class UserCell: UICollectionViewCell {

    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        contentView.backgroundColor = .systemOrange.withAlphaComponent(0.18)
        contentView.layer.cornerRadius = Theme.cardCornerRadius

        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.numberOfLines = 2

        usernameLabel.font = .preferredFont(forTextStyle: .subheadline)
        usernameLabel.adjustsFontForContentSizeCategory = true
        usernameLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
        stack.axis = .vertical
        stack.spacing = Theme.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        // Привязка к верху и низу нужна для self-sizing (Dynamic Type).
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.itemSpacing),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.itemSpacing),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.inset),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.inset)
        ])
    }

    func configure(with user: User) {
        nameLabel.text = user.name
        usernameLabel.text = "@\(user.username)"
    }
}
