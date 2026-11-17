import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewControllerDidAuthenticate(_ controller: AuthViewController)
}

final class AuthViewController: UIViewController {

    weak var delegate: AuthViewControllerDelegate?

    private let viewModel: AuthViewModel
    private let authView = AuthView()

    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func loadView() {
        view = authView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        authView.setSubmitTitle(viewModel.buttonTitle)
        authView.usernameField.delegate = self
        authView.passwordField.delegate = self
        authView.submitButton.addAction(
            UIAction { [weak self] _ in self?.submitTapped() },
            for: .touchUpInside
        )
    }

    // MARK: - Actions

    private func submitTapped() {
        view.endEditing(true)

        let result = viewModel.submit(
            username: authView.usernameField.text ?? "",
            password: authView.passwordField.text ?? ""
        )

        switch result {
        case .success:
            authView.isBusy = true
            FlashOverlay.show(color: .systemGreen, in: view) { [weak self] in
                guard let self else { return }
                self.delegate?.authViewControllerDidAuthenticate(self)
            }

        case .failure(.invalidCredentials):
            authView.isBusy = true
            FlashOverlay.show(color: .systemRed, in: view) { [weak self] in
                self?.authView.isBusy = false
                self?.showAlert(title: L10n.Auth.alertTitle, message: AuthError.invalidCredentials.localizedDescription)
            }

        case .failure(let error):
            showAlert(title: L10n.Auth.alertTitle, message: error.localizedDescription)
        }
    }
}

// MARK: - UITextFieldDelegate

extension AuthViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === authView.usernameField {
            authView.passwordField.becomeFirstResponder()
        } else {
            submitTapped()
        }
        return true
    }
}
