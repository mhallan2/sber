import UIKit

/// Индикатор загрузки с подписью.
final class LoadingStateView: UIStackView {

    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let label = UILabel()

    init(text: String) {
        super.init(frame: .zero)

        axis = .vertical
        alignment = .center
        spacing = 24

        activityIndicator.hidesWhenStopped = true

        label.text = text
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true

        addArrangedSubview(activityIndicator)
        addArrangedSubview(label)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func startAnimating() { activityIndicator.startAnimating() }
    func stopAnimating() { activityIndicator.stopAnimating() }
}
