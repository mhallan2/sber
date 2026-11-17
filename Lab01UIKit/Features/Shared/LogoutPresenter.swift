import UIKit

/// Алерт выхода и очистка данных. Раньше та же логика была скопирована
/// в `LoadingViewController` и `MainViewController`.
final class LogoutPresenter {

    private let sessionCleaner: SessionCleaning

    /// `true`, пока алерт на экране. Нужно экрану загрузки, чтобы не открывать
    /// ленту «из-под» алерта.
    private(set) var isPresenting = false

    init(sessionCleaner: SessionCleaning) {
        self.sessionCleaner = sessionCleaner
    }

    /// - Parameters:
    ///   - onCancel: пользователь отменил выход **или** очистка данных не удалась —
    ///     в обоих случаях экран остаётся на месте.
    ///   - onLoggedOut: выход выполнен, можно переходить на экран авторизации.
    func present(
        from presenter: UIViewController,
        onCancel: @escaping () -> Void = {},
        onLoggedOut: @escaping () -> Void
    ) {
        guard !isPresenting else { return }
        isPresenting = true

        let alert = UIAlertController(
            title: L10n.Logout.title,
            message: L10n.Logout.message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: L10n.Logout.keep, style: .default) { [weak self] _ in
            self?.isPresenting = false
            onLoggedOut()
        })

        alert.addAction(UIAlertAction(title: L10n.Logout.delete, style: .destructive) { [weak self, weak presenter] _ in
            guard let self else { return }
            self.isPresenting = false

            do {
                try self.sessionCleaner.clearAllLocalData()
                onLoggedOut()
            } catch {
                presenter?.showAlert(title: L10n.Common.error, message: L10n.Logout.deleteFailed)
                onCancel()
            }
        })

        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel) { [weak self] _ in
            self?.isPresenting = false
            onCancel()
        })

        presenter.present(alert, animated: true)
    }
}
