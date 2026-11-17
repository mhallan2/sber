
import UIKit

// MARK: - Collection Identifiers

private enum UserSection: Int, Sendable {
    case main
}

private enum PostSection: Int, Sendable {
    case main
}

// MARK: - Main View Controller

final class MainViewController: UIViewController {
    
    // MARK: - Search Properties

    private let searchTextField = UITextField()

    private var filteredUsers: [User] = []
    
    private var filteredPosts: [Post] = []

    private let searchStack = UIStackView()
    
    // MARK: - Navigation Buttons

    private let logoutButton = UIButton(type: .system)
    
    // MARK: - Data
    
    private let users: [User]
    private let posts: [Post]
    private var likedPostIds = Set(
        UserDefaults.standard.array(forKey: "likedPostIds") as? [Int] ?? []
    )
    
    // MARK: - Collection Views
    
    private var usersCollectionView: UICollectionView!
    private var postsCollectionView: UICollectionView!
    
    // MARK: - Data Sources
    
    private var usersDataSource:
    UICollectionViewDiffableDataSource<UserSection, Int>!
    
    private var postsDataSource:
    UICollectionViewDiffableDataSource<PostSection, Int>!
    
    // MARK: - UI Properties
    
    private let usersContainerView = UIView()
    private let usersTitleLabel = UILabel()
    private let postsTitleLabel = UILabel()
    
    // MARK: - Sort button
    private let sortButton = UIButton(type: .system)
    private var isAscendingSort = true
    
    // MARK: - Layout State
    
    private var usersHeightConstraint: NSLayoutConstraint!
    
    private let expandedUsersHeight: CGFloat = 180
    
    // MARK: - Scroll State
    
    private var previousScrollOffset: CGFloat = 0
    
    // MARK: - Initialization
    
    init(data: LoadedData) {
        self.filteredUsers = data.users
        self.users = data.users
        self.posts = data.posts
        self.filteredPosts = posts
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDataSources()
        applySnapshots()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Главная"

        setupSearchBar()
        setupTitles()
        setupCollectionViews()
        setupLayout()

        postsCollectionView.delegate = self
        usersCollectionView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(usersSectionTapped)
        )

        tapGesture.cancelsTouchesInView = false
        usersContainerView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func usersSectionTapped() {
        scrollViewWillBeginDragging(usersCollectionView)
    }
    
    private func setupTitles() {
        usersTitleLabel.text = "Пользователи"
        usersTitleLabel.font = .preferredFont(
            forTextStyle: .headline
        )
        
        postsTitleLabel.text = "Публикации"
        postsTitleLabel.font = .preferredFont(
            forTextStyle: .headline
        )
        
        sortButton.setImage(
            UIImage(systemName: "arrow.up.arrow.down"),
            for: .normal
        )

        sortButton.tintColor = .systemGreen
        sortButton.alpha = 0.5
        
        NSLayoutConstraint.activate([
            sortButton.widthAnchor.constraint(equalToConstant: 44),
            sortButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        sortButton.addTarget(
            self,
            action: #selector(sortButtonTapped),
            for: .touchUpInside
        )
    }
    
    private func setupCollectionViews() {
        usersCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createUsersLayout()
        )
        
        postsCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createPostsLayout()
        )
        
        postsCollectionView.keyboardDismissMode = .onDrag
        usersCollectionView.keyboardDismissMode = .onDrag
        
        usersCollectionView.backgroundColor = .clear
        postsCollectionView.backgroundColor = .clear
        
        usersCollectionView.register(
            UserCell.self,
            forCellWithReuseIdentifier: UserCell.reuseIdentifier
        )
        
        postsCollectionView.register(
            PostCell.self,
            forCellWithReuseIdentifier: PostCell.reuseIdentifier
        )
        
        // Горизонтальная коллекция не должна
        // влиять на вертикальную прокрутку.
        usersCollectionView.showsHorizontalScrollIndicator = false
        
        // Обрезаем содержимое при уменьшении высоты контейнера.
        usersContainerView.clipsToBounds = true

        // Отключаем принудительный вертикальный bounce.
        usersCollectionView.alwaysBounceVertical = false

        // Не показываем вертикальный индикатор.
        usersCollectionView.showsVerticalScrollIndicator = false
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        let postsHeaderView = UIView()
        
        usersContainerView.addSubview(usersTitleLabel)
        usersContainerView.addSubview(usersCollectionView)
        
        postsHeaderView.addSubview(postsTitleLabel)
        postsHeaderView.addSubview(sortButton)
        
        view.addSubview(usersContainerView)
        view.addSubview(postsHeaderView)
        view.addSubview(postsCollectionView)
        
        [
            usersContainerView,
            usersTitleLabel,
            usersCollectionView,
            postsHeaderView,
            postsTitleLabel,
            sortButton,
            postsCollectionView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        usersHeightConstraint =
        usersContainerView.heightAnchor.constraint(
            equalToConstant: expandedUsersHeight
        )
        
        NSLayoutConstraint.activate([
            usersContainerView.topAnchor.constraint(
                equalTo: searchStack.bottomAnchor,
                constant: 8
            ),
            usersContainerView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            usersContainerView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            usersHeightConstraint,
            
            usersTitleLabel.topAnchor.constraint(
                equalTo: usersContainerView.topAnchor,
                constant: 12
            ),
            usersTitleLabel.leadingAnchor.constraint(
                equalTo: usersContainerView.leadingAnchor,
                constant: 16
            ),
            
            usersCollectionView.topAnchor.constraint(
                equalTo: usersTitleLabel.bottomAnchor,
                constant: 12
            ),
            usersCollectionView.leadingAnchor.constraint(
                equalTo: usersContainerView.leadingAnchor
            ),
            usersCollectionView.trailingAnchor.constraint(
                equalTo: usersContainerView.safeAreaLayoutGuide.trailingAnchor
            ),
            usersCollectionView.heightAnchor.constraint(
                equalToConstant: 122
            ),
            
            postsHeaderView.topAnchor.constraint(
                equalTo: usersContainerView.bottomAnchor
            ),
            postsHeaderView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            postsHeaderView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            postsHeaderView.heightAnchor.constraint(
                equalToConstant: 48
            ),
            
            postsTitleLabel.centerYAnchor.constraint(
                equalTo: postsHeaderView.centerYAnchor
            ),
            postsTitleLabel.leadingAnchor.constraint(
                equalTo: postsHeaderView.leadingAnchor,
                constant: 16
            ),
            
            postsCollectionView.topAnchor.constraint(
                equalTo: postsHeaderView.bottomAnchor
            ),
            postsCollectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            postsCollectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            postsCollectionView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            
            sortButton.centerYAnchor.constraint(
                equalTo: postsHeaderView.centerYAnchor
            ),
            sortButton.trailingAnchor.constraint(
                equalTo: postsHeaderView.trailingAnchor,
                constant: -16
            ),
            sortButton.leadingAnchor.constraint(
                greaterThanOrEqualTo: postsTitleLabel.trailingAnchor,
                constant: 8
            ),
        ])
    }
    
    // MARK: - Search Setup

    private func setupSearchBar() {
        searchTextField.placeholder = "Поиск пользователей"
        searchTextField.borderStyle = .roundedRect
        searchTextField.autocapitalizationType = .none
        searchTextField.autocorrectionType = .no
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.returnKeyType = .search

        let searchIcon = UIImageView(
            image: UIImage(systemName: "magnifyingglass")
        )
        searchIcon.tintColor = .systemBlue
        searchIcon.contentMode = .center
        searchIcon.frame = CGRect(
            x: 12,
            y: 0,
            width: 24,
            height: 36
        )

        let iconContainer = UIView(
            frame: CGRect(x: 0, y: 0, width: 36, height: 36)
        )
        searchIcon.frame = CGRect(x: 8, y: 0, width: 24, height: 36)
        iconContainer.addSubview(searchIcon)

        searchTextField.leftView = iconContainer
        searchTextField.leftViewMode = .always

        searchTextField.addTarget(
            self,
            action: #selector(searchTextChanged),
            for: .editingChanged
        )

        logoutButton.setImage(
            UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            for: .normal
        )

        logoutButton.addTarget(
            self,
            action: #selector(logoutTapped),
            for: .touchUpInside
        )

//        let searchStack = UIStackView(arrangedSubviews: [
//            searchTextField,
//            logoutButton
//        ])
        searchStack.addArrangedSubview(searchTextField)
        searchStack.addArrangedSubview(logoutButton)

        searchStack.axis = .horizontal
        searchStack.spacing = 12
        searchStack.alignment = .center

        view.addSubview(searchStack)
        searchStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchStack.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 8
            ),
            searchStack.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            searchStack.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),

            searchTextField.heightAnchor.constraint(
                equalToConstant: 40
            ),

            logoutButton.widthAnchor.constraint(
                equalToConstant: 36
            ),
            logoutButton.heightAnchor.constraint(
                equalToConstant: 36
            )
        ])
    }
    
    // MARK: - Sort action
    
    @objc private func sortButtonTapped() {
        isAscendingSort.toggle()

        sortButton.tintColor = isAscendingSort
            ? .systemGreen
            : .systemRed

        applyPostsSnapshot()
    }
    
    // MARK: - Logout

    @objc private func logoutTapped() {
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
        )

        alert.addAction(keepAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
    
    private func finishLogout(keepCredentials: Bool) {
        if !keepCredentials {
            let success = AuthService.shared.logout()
            
            guard success else {
                showAlert(message: "Не удалось удалить данные")
                return
            }
            
            UserDefaults.standard.removeObject(forKey: "likedPostIds")
        }

        let authController = LoginViewController()

        navigationController?.setViewControllers(
            [authController],
            animated: true
        )
    }
    
    private func performLogout() {
        // Здесь вызови существующий метод AuthService,
        // который удаляет логин из UserDefaults
        // и пароль из Keychain.

        let loginController = LoginViewController()

        navigationController?.setViewControllers(
            [loginController],
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
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(alert, animated: true)
    }
    
    // MARK: - Search Handling
    
    @objc private func searchTextChanged() {
        let query = searchTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if query.isEmpty {
            filteredUsers = users
        } else if query.hasPrefix("@") {
            let usernameQuery = String(query.dropFirst())

            filteredUsers = users.filter { user in
                user.username.localizedCaseInsensitiveContains(usernameQuery)
            }
        } else {
            filteredUsers = users.filter { user in
                user.name.localizedCaseInsensitiveContains(query) ||
                user.username.localizedCaseInsensitiveContains(query) ||
                user.email.localizedCaseInsensitiveContains(query)
            }
        }

        let matchingUserIds = Set(filteredUsers.map { $0.id })

        filteredPosts = posts.filter { post in
            matchingUserIds.contains(post.userId)
        }

        applyUsersSnapshot()
        applyPostsSnapshot()
    }
    
    // MARK: - Compositional Layout
    
    private func createUsersLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(220),
            heightDimension: .absolute(110)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 12
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        )
        
        let configuration =
        UICollectionViewCompositionalLayoutConfiguration()
        
        configuration.scrollDirection = .horizontal
        
        return UICollectionViewCompositionalLayout(
            section: section,
            configuration: configuration
        )
    }
    
    private func createPostsLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(140)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(140)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 12
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 16,
            bottom: 24,
            trailing: 16
        )
        
        return UICollectionViewCompositionalLayout(
            section: section
        )
    }
    
    // MARK: - Diffable Data Sources
    
    private func setupDataSources() {
        setupUsersDataSource()
        setupPostsDataSource()
    }
    
    private func setupUsersDataSource() {
        usersDataSource =
        UICollectionViewDiffableDataSource<UserSection, Int>(
            collectionView: usersCollectionView
        ) { [weak self] collectionView, indexPath, id in
            
            guard let self,
                  let user = self.users.first(
                    where: { $0.id == id }
                  ),
                  let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: UserCell.reuseIdentifier,
                    for: indexPath
                  ) as? UserCell else {
                return nil
            }
            
            cell.configure(with: user)
            return cell
        }
    }
    
    private func setupPostsDataSource() {
        postsDataSource =
        UICollectionViewDiffableDataSource<PostSection, Int>(
            collectionView: postsCollectionView
        ) { [weak self] collectionView, indexPath, id in
            
            guard let self,
                  let post = self.posts.first(
                    where: { $0.id == id }
                  ),
                  let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PostCell.reuseIdentifier,
                    for: indexPath
                  ) as? PostCell else {
                return nil
            }
            
            let author = self.users.first { user in
                user.id == post.userId
            }

            cell.configure(
                with: post,
                authorName: author?.name ?? "Неизвестный автор",
                isLiked: self.likedPostIds.contains(post.id)
            )
            
            cell.onLikeTapped = { [weak self] in
                self?.toggleLike(for: post.id)
            }
            return cell
        }
    }
    
    private func toggleLike(for postId: Int) {
        if likedPostIds.contains(postId) {
            likedPostIds.remove(postId)
        } else {
            likedPostIds.insert(postId)
        }
        
        var snapshot = postsDataSource.snapshot()
        snapshot.reconfigureItems([postId])

        postsDataSource.apply(
            snapshot,
            animatingDifferences: false
        )
        
        UserDefaults.standard.set(
            Array(likedPostIds),
            forKey: "likedPostIds"
        )
    }
    
    // MARK: - Snapshots

    private func applySnapshots() {
        applyUsersSnapshot()
        applyPostsSnapshot()
    }

    private func applyUsersSnapshot() {
        var snapshot =
            NSDiffableDataSourceSnapshot<UserSection, Int>()

        snapshot.appendSections([.main])

        snapshot.appendItems(
            filteredUsers.map { $0.id },
            toSection: .main
        )

        usersDataSource.apply(
            snapshot,
            animatingDifferences: true
        )
    }

    private func applyPostsSnapshot() {
        var snapshot =
            NSDiffableDataSourceSnapshot<PostSection, Int>()

        snapshot.appendSections([.main])

        let sortedPosts = filteredPosts.sorted {
            if isAscendingSort {
                return $0.id < $1.id
            } else {
                return $0.id > $1.id
            }
        }

        snapshot.appendItems(
            sortedPosts.map { $0.id },
            toSection: .main
        )

        postsDataSource.apply(
            snapshot,
            animatingDifferences: false
        )
    }
    
    // MARK: - Users Section Visibility
    
    private func updateUsersSectionHeight(by scrollDelta: CGFloat) {
        let hideSensitivity: CGFloat = 0.2
        let showSensitivity: CGFloat = 0.8
        
        let sensitivity = scrollDelta > 0
        ? hideSensitivity
        : showSensitivity
        
        let currentHeight = usersHeightConstraint.constant
        
        let newHeight = currentHeight - scrollDelta * sensitivity
        
        let clampedHeight = min(
            expandedUsersHeight,
            max(0, newHeight)
        )
        
        guard currentHeight != clampedHeight else {
            return
        }
        
        usersHeightConstraint.constant = clampedHeight
        
        usersContainerView.alpha =
        clampedHeight / expandedUsersHeight
        
        view.layoutIfNeeded()
    }
}

// MARK: - Scroll Handling

extension MainViewController: UICollectionViewDelegate {

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === postsCollectionView else {
            return
        }

        let currentOffset = scrollView.contentOffset.y
        let scrollDelta = currentOffset - previousScrollOffset

        previousScrollOffset = currentOffset

        // Не реагируем на оттягивание списка за верхнюю границу.
        guard currentOffset > -scrollView.adjustedContentInset.top else {
            return
        }

        updateUsersSectionHeight(by: scrollDelta)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === usersCollectionView else {
            return
        }

        usersHeightConstraint.constant = expandedUsersHeight

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseOut]
        ) {
            self.usersContainerView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
}
