import UIKit

protocol PostCellDelegate: AnyObject {
    func postCell(_ cell: PostCell, didTapLikeFor postID: Post.ID)
}

final class PostCell: UICollectionViewCell {

    weak var delegate: PostCellDelegate?
    private var postID: Post.ID?

    private let authorLabel = UILabel()
    private let authorIconView = UIImageView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let postNumberLabel = UILabel()
    private let likeButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        postID = nil
        delegate = nil
    }

    // MARK: - UI

    private func setupUI() {
        contentView.backgroundColor = .systemGreen.withAlphaComponent(0.18)
        contentView.layer.cornerRadius = Theme.cardCornerRadius

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0

        bodyLabel.font = .preferredFont(forTextStyle: .body)
        bodyLabel.adjustsFontForContentSizeCategory = true
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 0

        authorLabel.font = .systemFont(ofSize: 13, weight: .medium)
        authorLabel.textColor = .secondaryLabel
        authorLabel.numberOfLines = 1

        authorIconView.image = UIImage(systemName: "person.circle")
        authorIconView.tintColor = .secondaryLabel
        authorIconView.contentMode = .scaleAspectFit

        postNumberLabel.font = .systemFont(ofSize: 12)
        postNumberLabel.textColor = .secondaryLabel

        likeButton.tintColor = .systemGray
        likeButton.contentHorizontalAlignment = .leading
        likeButton.addAction(UIAction { [weak self] _ in self?.likeTapped() }, for: .touchUpInside)

        let authorStack = UIStackView(arrangedSubviews: [authorIconView, authorLabel])
        authorStack.axis = .horizontal
        authorStack.spacing = 6
        authorStack.alignment = .center

        NSLayoutConstraint.activate([
            authorIconView.widthAnchor.constraint(equalToConstant: 18),
            authorIconView.heightAnchor.constraint(equalToConstant: 18)
        ])

        let headerStack = UIStackView(arrangedSubviews: [authorStack, UIView(), postNumberLabel])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = Theme.spacing

        let stack = UIStackView(arrangedSubviews: [headerStack, titleLabel, bodyLabel, likeButton])
        stack.axis = .vertical
        stack.spacing = Theme.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.inset),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.inset),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.inset),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.inset)
        ])
    }

    private func likeTapped() {
        guard let postID else { return }
        delegate?.postCell(self, didTapLikeFor: postID)
    }

    // MARK: - Configuration

    func configure(with post: Post, authorName: String, isLiked: Bool) {
        postID = post.id

        authorLabel.text = authorName
        postNumberLabel.text = L10n.Feed.postNumber(post.id)
        titleLabel.text = post.title
        bodyLabel.text = post.body

        likeButton.setImage(UIImage(systemName: isLiked ? "heart.fill" : "heart"), for: .normal)
        likeButton.tintColor = isLiked ? .systemRed : .systemGray
        likeButton.accessibilityLabel = isLiked ? L10n.Feed.unlike : L10n.Feed.like
    }
}
