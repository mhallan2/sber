//
//  PostCell.swift
//  Lab01UIKit
//
//  Created by Елизавета on 17.11.2026.
//


import UIKit

final class PostCell: UICollectionViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "PostCell"
    
    private let authorLabel = UILabel()
    private let authorIconView = UIImageView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let postNumberLabel = UILabel()
    private let likeButton = UIButton(type: .system)

    var onLikeTapped: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup

    private func setupUI() {
        contentView.backgroundColor = .systemGreen.withAlphaComponent(0.18)
        contentView.layer.cornerRadius = 16

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0

        bodyLabel.font = .preferredFont(forTextStyle: .body)
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
        likeButton.addTarget(
            self,
            action: #selector(likeTapped),
            for: .touchUpInside
        )
        
        let authorStack = UIStackView(arrangedSubviews: [
            authorIconView,
            authorLabel
        ])

        authorStack.axis = .horizontal
        authorStack.spacing = 6
        authorStack.alignment = .center

        NSLayoutConstraint.activate([
            authorIconView.widthAnchor.constraint(equalToConstant: 18),
            authorIconView.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        let spacer = UIView()

        let headerStack = UIStackView(arrangedSubviews: [
            authorStack,
            spacer,
            postNumberLabel
        ])

        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 8

        let stack = UIStackView(arrangedSubviews: [
            headerStack,
            titleLabel,
            bodyLabel,
            likeButton
        ])

        stack.axis = .vertical
        stack.spacing = 8

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 16
            ),
            stack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -16
            ),
            stack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            stack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            )
        ])
    }
    
    @objc private func likeTapped() {
        onLikeTapped?()
    }
    
    // MARK: - Configuration

    func configure(
        with post: Post,
        authorName: String,
        isLiked: Bool
    ) {
        authorLabel.text = authorName
        postNumberLabel.text = "Пост №\(post.id)"

        titleLabel.text = post.title
        bodyLabel.text = post.body

        let imageName = isLiked ? "heart.fill" : "heart"

        likeButton.setImage(
            UIImage(systemName: imageName),
            for: .normal
        )

        likeButton.tintColor = isLiked ? .systemRed : .systemGray
    }
}
