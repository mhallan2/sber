import UIKit

/// Иконка + текст ошибки + кнопка «Повторить».
final class ErrorStateView: UIStackView {

    var onRetry: (() -> Void)?

    private let imageView = UIImageView()
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    init() {
        super.init(frame: .zero)

        axis = .vertical
        alignment = .center
        spacing = 24

        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemRed
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 48),
            imageView.heightAnchor.constraint(equalToConstant: 48)
        ])

        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.adjustsFontForContentSizeCategory = true

        var config = UIButton.Configuration.filled()
        config.title = L10n.Loading.retry
        retryButton.configuration = config
        retryButton.addAction(UIAction { [weak self] _ in self?.onRetry?() }, for: .touchUpInside)

        addArrangedSubview(imageView)
        addArrangedSubview(messageLabel)
        addArrangedSubview(retryButton)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(message: String, iconName: String) {
        messageLabel.text = message
        imageView.image = UIImage(systemName: iconName)
    }
}
