import UIKit

protocol FeedViewControllerDelegate: AnyObject {
    func feedViewControllerDidLogout(_ controller: FeedViewController)
}

/// Только жизненный цикл и связывание: логика — во `FeedViewModel`,
/// раскладка — в `FeedLayoutFactory`, данные — в `FeedDataSource`.
final class FeedViewController: UIViewController {

    weak var delegate: FeedViewControllerDelegate?

    private let viewModel: FeedViewModel
    private let logoutPresenter: LogoutPresenter

    private let topBar = FeedTopBarView()
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: FeedLayoutFactory.makeLayout()
    )
    private var feedDataSource: FeedDataSource?

    init(viewModel: FeedViewModel, logoutPresenter: LogoutPresenter) {
        self.viewModel = viewModel
        self.logoutPresenter = logoutPresenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Feed.title
        view.backgroundColor = .systemBackground

        setupLayout()
        feedDataSource = FeedDataSource(
            collectionView: collectionView,
            viewModel: viewModel,
            postCellDelegate: self
        )
        bind()

        topBar.setSortAscending(viewModel.isAscending)
        reloadContent(animated: false)
    }

    // MARK: - Setup

    private func setupLayout() {
        topBar.searchTextField.delegate = self

        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        collectionView.alwaysBounceVertical = true

        [topBar, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Theme.spacing),
            topBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Theme.inset),
            topBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Theme.inset),

            collectionView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: Theme.spacing),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bind() {
        viewModel.onContentChange = { [weak self] animated in
            self?.reloadContent(animated: animated)
        }
        viewModel.onLikeChange = { [weak self] postID in
            self?.feedDataSource?.reconfigurePost(id: postID)
        }
        viewModel.onSortOrderChange = { [weak self] isAscending in
            self?.topBar.setSortAscending(isAscending)
        }

        topBar.onSearchChange = { [weak self] query in self?.viewModel.updateQuery(query) }
        topBar.onSortTap = { [weak self] in self?.viewModel.toggleSortOrder() }
        topBar.onLogoutTap = { [weak self] in self?.logoutTapped() }
    }

    private func reloadContent(animated: Bool) {
        feedDataSource?.apply(
            users: viewModel.visibleUsers,
            posts: viewModel.visiblePosts,
            animated: animated
        )
    }

    // MARK: - Logout

    private func logoutTapped() {
        logoutPresenter.present(from: self, onLoggedOut: { [weak self] in
            guard let self else { return }
            self.delegate?.feedViewControllerDidLogout(self)
        })
    }
}

// MARK: - PostCellDelegate

extension FeedViewController: PostCellDelegate {

    func postCell(_ cell: PostCell, didTapLikeFor postID: Post.ID) {
        viewModel.toggleLike(postID)
    }
}

// MARK: - UITextFieldDelegate

extension FeedViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
