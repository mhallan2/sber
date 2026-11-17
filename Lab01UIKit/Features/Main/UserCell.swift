//
//  UserCekk.swift
//  Lab01UIKit
//
//  Created by Елизавета on 17.11.2026.
//


import UIKit

final class UserCell: UICollectionViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "UserCell"

    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()

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
        contentView.backgroundColor = .systemOrange.withAlphaComponent(0.18)
        contentView.layer.cornerRadius = 16

        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.numberOfLines = 2

        usernameLabel.font = .preferredFont(forTextStyle: .subheadline)
        usernameLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [
            nameLabel,
            usernameLabel
        ])

        stack.axis = .vertical
        stack.spacing = 8

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            stack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            stack.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            )
        ])
    }

    // MARK: - Configuration

    func configure(with user: User) {
        nameLabel.text = user.name
        usernameLabel.text = "@\(user.username)"
    }
}
