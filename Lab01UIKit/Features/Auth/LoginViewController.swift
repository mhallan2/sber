
import UIKit

final class LoginViewController: UIViewController {

    private enum AuthMode {
        case login
        case registration
    }

    private var authMode: AuthMode = .registration

    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let authButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Удаляем старую небезопасную копию пароля,
        UserDefaults.standard.removeObject(
            forKey: "registeredPassword"
        )
        
        authMode = AuthService.shared.hasRegisteredUser
            ? .login
            : .registration

        setupUI()
        updateAuthButton()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        setupFields()
        setupButton()
        setupLayout()
    }

    private func setupFields() {
        usernameField.placeholder = "Логин"
        usernameField.borderStyle = .roundedRect
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        usernameField.keyboardType = .asciiCapable

        passwordField.placeholder = "Пароль"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .none
    }

    private func setupButton() {
        var config = UIButton.Configuration.filled()
        config.title = "Продолжить"

        authButton.configuration = config

        authButton.addTarget(
            self,
            action: #selector(authButtonTapped),
            for: .touchUpInside
        )
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [
            usernameField,
            passwordField,
            authButton
        ])

        stack.axis = .vertical
        stack.spacing = 16

        view.addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        
        let widthConstraint = stack.widthAnchor.constraint(
            equalToConstant: 400
        )
        widthConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            widthConstraint,
            
            stack.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor
            ),
            // Отступы от краёв не менее 24 pt
            stack.leadingAnchor.constraint(
                greaterThanOrEqualTo: safeArea.leadingAnchor,
                constant: 24
            ),

            stack.trailingAnchor.constraint(
                lessThanOrEqualTo: safeArea.trailingAnchor,
                constant: -24
            ),
            stack.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerYAnchor
            ),
            usernameField.heightAnchor.constraint(
                equalToConstant: 48
            ),
            passwordField.heightAnchor.constraint(
                equalToConstant: 48
            ),
            authButton.heightAnchor.constraint(
                equalToConstant: 48
            )
        ])
    }

    // MARK: - Authentication Button

    private func updateAuthButton() {
        switch authMode {
        case .login:
            authButton.configuration?.title = "Войти"
        case .registration:
            authButton.configuration?.title = "Зарегистрироваться"
        }
    }

    @objc private func authButtonTapped() {
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""

        guard !username.isEmpty, !password.isEmpty else {
            showAlert(message: "Заполните логин и пароль")
            return
        }

        switch authMode {
        case .login:
            performLogin(
                username: username,
                password: password
            )

        case .registration:
            performRegistration(
                username: username,
                password: password
            )
        }
    }

    // MARK: - Authentication

    private func performLogin(
        username: String,
        password: String
    ) {
        let isValid = AuthService.shared.login(
            username: username,
            password: password
        )

        if isValid {
            openLoadingScreen()
        } else {
            showSuccessWaves(color: .systemRed) { [weak self] in
                    self?.showAlert(message: "Неверный логин или пароль")
                }
            showAlert(message: "Неверный логин или пароль")
        }
    }

    private func performRegistration(
        username: String,
        password: String
    ) {
        let success = AuthService.shared.register(
            username: username,
            password: password
        )

        guard success else {
            showAlert(message: "Не удалось сохранить данные")
            return
        }

        openLoadingScreen()
    }
    
    // MARK: - Success animation
    
    private func showSuccessWaves(color: UIColor, completion: @escaping () -> Void) {
        let overlay = UIView(frame: view.bounds)

        overlay.backgroundColor = color
        overlay.alpha = 0
        overlay.isUserInteractionEnabled = false
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.insertSubview(overlay, at: 0)

        UIView.animate(
            withDuration: 0.3,
            animations: {
                overlay.alpha = 0.2
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.4,
                    animations: {
                        overlay.alpha = 0
                    },
                    completion: { _ in
                        overlay.removeFromSuperview()
                        completion()
                    }
                )
            }
        )
    }
    
    // MARK: - Navigation

    private func openLoadingScreen() {
        let loadingController = LoadingViewController()

        showSuccessWaves(color: .systemGreen) { [weak self] in
            self?.navigationController?.pushViewController(
                loadingController,
                animated: true
            )
        }
    }

    // MARK: - Alerts

    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Авторизация",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
    }
}
