import UIKit

/// Вёрстка экрана авторизации. Контроллер только связывает её с моделью.
final class AuthView: UIView {

    let usernameField = UITextField()
    let passwordField = UITextField()
    let submitButton = UIButton(type: .system)

    /// Блокирует ввод на время анимации перехода (защита от двойного тапа).
    var isBusy = false {
        didSet {
            submitButton.isEnabled = !isBusy
            usernameField.isEnabled = !isBusy
            passwordField.isEnabled = !isBusy
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupFields()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSubmitTitle(_ title: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        submitButton.configuration = config
    }

    private func setupFields() {
        usernameField.placeholder = L10n.Auth.usernamePlaceholder
        usernameField.borderStyle = .roundedRect
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        usernameField.keyboardType = .asciiCapable
        usernameField.returnKeyType = .next

        passwordField.placeholder = L10n.Auth.passwordPlaceholder
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .none
        passwordField.returnKeyType = .go
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [usernameField, passwordField, submitButton])
        stack.axis = .vertical
        stack.spacing = Theme.inset
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        let safeArea = safeAreaLayoutGuide

        let widthConstraint = stack.widthAnchor.constraint(equalToConstant: 400)
        widthConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            widthConstraint,
            stack.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: safeArea.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: safeArea.trailingAnchor, constant: -24),

            usernameField.heightAnchor.constraint(equalToConstant: Theme.controlHeight),
            passwordField.heightAnchor.constraint(equalToConstant: Theme.controlHeight),
            submitButton.heightAnchor.constraint(equalToConstant: Theme.controlHeight)
        ])
    }
}
