import UIKit

/// Управляет переходами: авторизация → загрузка → лента → (выход) → авторизация.
/// Контроллеры сообщают о событиях через делегаты и ничего не знают друг о друге.
final class AppCoordinator {

    private let window: UIWindow
    private let dependencies: AppDependencies
    private let navigationController = UINavigationController()

    init(window: UIWindow, dependencies: AppDependencies) {
        self.window = window
        self.dependencies = dependencies
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        showAuth(animated: false)
    }

    // MARK: - Screens

    private func showAuth(animated: Bool) {
        // Модель создаётся заново: режим (вход / регистрация) зависит от текущего состояния хранилища.
        let viewModel = AuthViewModel(authService: dependencies.authService)
        let controller = AuthViewController(viewModel: viewModel)
        controller.delegate = self
        navigationController.setViewControllers([controller], animated: animated)
    }

    private func showLoading() {
        let viewModel = LoadingViewModel(repository: dependencies.feedRepository)
        let controller = LoadingViewController(
            viewModel: viewModel,
            logoutPresenter: dependencies.makeLogoutPresenter()
        )
        controller.delegate = self
        // setViewControllers вместо push: с экрана загрузки нельзя «вернуться назад» в обход выхода.
        navigationController.setViewControllers([controller], animated: true)
    }

    private func showFeed(with content: FeedContent) {
        let viewModel = FeedViewModel(
            content: content,
            likes: dependencies.likesStore,
            sortOrderStore: dependencies.sortOrderStore
        )
        let controller = FeedViewController(
            viewModel: viewModel,
            logoutPresenter: dependencies.makeLogoutPresenter()
        )
        controller.delegate = self
        navigationController.setViewControllers([controller], animated: true)
    }
}

// MARK: - AuthViewControllerDelegate

extension AppCoordinator: AuthViewControllerDelegate {

    func authViewControllerDidAuthenticate(_ controller: AuthViewController) {
        showLoading()
    }
}

// MARK: - LoadingViewControllerDelegate

extension AppCoordinator: LoadingViewControllerDelegate {

    func loadingViewController(_ controller: LoadingViewController, didLoad content: FeedContent) {
        showFeed(with: content)
    }

    func loadingViewControllerDidLogout(_ controller: LoadingViewController) {
        showAuth(animated: true)
    }
}

// MARK: - FeedViewControllerDelegate

extension AppCoordinator: FeedViewControllerDelegate {

    func feedViewControllerDidLogout(_ controller: FeedViewController) {
        showAuth(animated: true)
    }
}
