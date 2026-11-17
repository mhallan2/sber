//
//  LoadingViewController.swift
//  Lab01UIKit
//
//  Created by Елизавета on 17.11.2026.
//


import UIKit

final class LoadingViewController: UIViewController {

    private let activityIndicator = UIActivityIndicatorView(
        style: .large
    )

    private let statusLabel = UILabel()
    private let errorImageView = UIImageView()
    private let logoutButton = UIButton(type: .system)
    private let retryButton = UIButton(type: .system)
    private var loadingTask: Task<Void, Never>?
    // MARK: - Loading State

    private var isLogoutAlertPresented = false
    private var pendingLoadedData: LoadedData?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startLoading()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        setupIndicator()
        setupErrorImage()
        setupLabel()
        setupLogoutButton()
        setupRetryButton()
        setupLayout()
    }

    private func setupIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }

    private func setupErrorImage() {
        errorImageView.contentMode = .scaleAspectFit
        errorImageView.tintColor = .systemRed
        errorImageView.isHidden = true

        errorImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            errorImageView.widthAnchor.constraint(equalToConstant: 48),
            errorImageView.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupLabel() {
        statusLabel.text = "Загружаем данные..."
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
    }

    private func setupLogoutButton() {
        var config = UIButton.Configuration.plain()
        config.title = "Выйти"

        logoutButton.configuration = config

        logoutButton.addTarget(
            self,
            action: #selector(logoutTapped),
            for: .touchUpInside
        )
    }

    private func setupRetryButton() {
        var config = UIButton.Configuration.filled()
        config.title = "Повторить попытку"

        retryButton.configuration = config
        retryButton.isHidden = true

        retryButton.addTarget(
            self,
            action: #selector(retryTapped),
            for: .touchUpInside
        )
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [
            activityIndicator,
            errorImageView,
            statusLabel,
            retryButton,
            logoutButton
        ])

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 24

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerYAnchor
            ),
            stack.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 24
            ),
            stack.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -24
            )
        ])
    }

    // MARK: - Data Loading

    private func startLoading() {
//        if true {
//            showLoadingError(URLError(.timedOut))
//            return
//        }
        
        loadingTask?.cancel()
        
        errorImageView.isHidden = true
        retryButton.isHidden = true
        statusLabel.text = "Загружаем данные..."
        activityIndicator.startAnimating()

        loadingTask = Task { [weak self] in
            guard let self else { return }

            do {
//              sleep(2)
                async let users = APIService.shared.fetchUsers()
                async let posts = APIService.shared.fetchPosts()

                let loadedData = try await LoadedData(
                    users: users,
                    posts: posts
                )

                try Task.checkCancellation()

                self.loadingTask = nil

                if self.isLogoutAlertPresented {
                    self.pendingLoadedData = loadedData
                } else {
                    self.openMainScreen(with: loadedData)
                }

            } catch {
                guard !Task.isCancelled else { return }

                self.loadingTask = nil
                self.showLoadingError(error)
            }
        }
    }

    @objc private func retryTapped() {
        startLoading()
    }

    private func openMainScreen(with data: LoadedData) {
        activityIndicator.stopAnimating()

        let mainController = MainViewController(data: data)

        navigationController?.setViewControllers(
            [mainController],
            animated: true
        )
    }

    // MARK: - Loading Errors

    private func showLoadingError(_ error: Error) {
        activityIndicator.stopAnimating()

        let iconName = errorIcon(for: error)

        errorImageView.image = UIImage(systemName: iconName)
        errorImageView.isHidden = false

        statusLabel.text = """
        Не удалось загрузить данные.

        Причина: \(errorMessage(for: error))
        """

        retryButton.isHidden = false
    }


    private func errorMessage(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "Нет подключения к интернету."

            case .timedOut:
                return "Превышено время ожидания ответа от сервера."

            case .cannotFindHost:
                return "Не удалось найти сервер."

            case .cannotConnectToHost:
                return "Не удалось подключиться к серверу."

            default:
                return urlError.localizedDescription
            }
        }

        return error.localizedDescription
    }

    private func errorIcon(for error: Error) -> String {

        if let urlError = error as? URLError {
            switch urlError.code {

            case .notConnectedToInternet:
                return "wifi.slash"

            case .timedOut:
                return "clock.badge.exclamationmark"

            case .cannotFindHost, .cannotConnectToHost:
                return "network.slash"

            default:
                return "exclamationmark.triangle"
            }
        }

        if error is DecodingError {
            return "doc.text.magnifyingglass"
        }

        return "exclamationmark.triangle"
    }

    // MARK: - Sign-Out

    @objc private func logoutTapped() {
        guard !isLogoutAlertPresented else { return }

        isLogoutAlertPresented = true

        let alert = UIAlertController(
            title: "Выход",
            message: "Сохранить данные для следующего входа?",
            preferredStyle: .alert
        )

        let keepAction = UIAlertAction(
            title: "Сохранить данные",
            style: .default
        ) { [weak self] _ in
            self?.finishLogout(keepCredentials: true)
        }

        let deleteAction = UIAlertAction(
            title: "Удалить данные",
            style: .destructive
        ) { [weak self] _ in
            self?.finishLogout(keepCredentials: false)
        }

        let cancelAction = UIAlertAction(
            title: "Отмена",
            style: .cancel
        ) { [weak self] _ in
            self?.cancelLogout()
        }

        alert.addAction(keepAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
    
    private func cancelLogout() {
        isLogoutAlertPresented = false

        if let data = pendingLoadedData {
            pendingLoadedData = nil
            openMainScreen(with: data)
        }
    }
    
    private func finishLogout(keepCredentials: Bool) {
        if !keepCredentials {
            let success = AuthService.shared.logout()

            guard success else {
                isLogoutAlertPresented = false

                showAlert(message: "Не удалось удалить данные")

                return
            }
        }

        // Отменяем незавершённую загрузку.
        loadingTask?.cancel()
        loadingTask = nil

        // Удаляем результат, который мог прийти,
        // пока пользователь выбирал действие.
        pendingLoadedData = nil

        isLogoutAlertPresented = false

        let authController = LoginViewController()

        navigationController?.setViewControllers(
            [authController],
            animated: true
        )
    }

    // MARK: - Alerts

    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
    }
}
