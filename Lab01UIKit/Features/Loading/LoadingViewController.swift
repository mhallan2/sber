import UIKit

protocol LoadingViewControllerDelegate: AnyObject {
    func loadingViewController(_ controller: LoadingViewController, didLoad content: FeedContent)
    func loadingViewControllerDidLogout(_ controller: LoadingViewController)
}

final class LoadingViewController: UIViewController {

    weak var delegate: LoadingViewControllerDelegate?

    private let viewModel: LoadingViewModel
    private let logoutPresenter: LogoutPresenter

    private let loadingView = LoadingStateView(text: L10n.Loading.inProgress)
    private let errorView = ErrorStateView()
    private let logoutButton = UIButton(type: .system)

    /// Данные, которые пришли, пока на экране был алерт выхода.
    private var pendingContent: FeedContent?

    init(viewModel: LoadingViewModel, logoutPresenter: LogoutPresenter) {
        self.viewModel = viewModel
        self.logoutPresenter = logoutPresenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        viewModel.load()
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .systemBackground

        var config = UIButton.Configuration.plain()
        config.title = L10n.Logout.buttonTitle
        logoutButton.configuration = config
        logoutButton.addAction(UIAction { [weak self] _ in self?.logoutTapped() }, for: .touchUpInside)

        errorView.onRetry = { [weak self] in self?.viewModel.load() }

        let stack = UIStackView(arrangedSubviews: [loadingView, errorView, logoutButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }

    // MARK: - State rendering

    private func render(_ state: LoadingViewModel.State) {
        switch state {
        case .loading:
            errorView.isHidden = true
            loadingView.isHidden = false
            loadingView.startAnimating()

        case .failed(let info):
            loadingView.stopAnimating()
            loadingView.isHidden = true
            errorView.configure(message: info.message, iconName: info.iconName)
            errorView.isHidden = false

        case .loaded(let content):
            loadingView.stopAnimating()
            open(content)
        }
    }

    private func open(_ content: FeedContent) {
        if logoutPresenter.isPresenting {
            // Не перебиваем алерт: откроем ленту, если пользователь его отменит.
            pendingContent = content
        } else {
            delegate?.loadingViewController(self, didLoad: content)
        }
    }

    // MARK: - Logout

    private func logoutTapped() {
        logoutPresenter.present(
            from: self,
            onCancel: { [weak self] in
                // Отмена и ошибка очистки приходят сюда одинаково:
                // если данные уже загружены — открываем ленту, иначе просто ждём.
                guard let self, let content = self.pendingContent else { return }
                self.pendingContent = nil
                self.delegate?.loadingViewController(self, didLoad: content)
            },
            onLoggedOut: { [weak self] in
                guard let self else { return }
                self.viewModel.cancel()
                self.pendingContent = nil
                self.delegate?.loadingViewControllerDidLogout(self)
            }
        )
    }
}
