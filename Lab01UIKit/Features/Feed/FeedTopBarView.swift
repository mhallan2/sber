import UIKit

/// Верхняя панель по макету: [выход] [поиск] [сортировка].
final class FeedTopBarView: UIView {

    let searchTextField = UITextField()

    var onLogoutTap: (() -> Void)?
    var onSortTap: (() -> Void)?
    var onSearchChange: ((String) -> Void)?

    private let logoutButton = UIButton(type: .system)
    private let sortButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLogoutButton()
        setupSearchField()
        setupSortButton()
        setupLayout()
        setSortAscending(true)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSortAscending(_ isAscending: Bool) {
        sortButton.tintColor = isAscending ? .systemGreen : .systemRed
        sortButton.accessibilityValue = isAscending ? L10n.Feed.sortAscending : L10n.Feed.sortDescending
    }

    // MARK: - Setup

    private func setupLogoutButton() {
        logoutButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        logoutButton.accessibilityLabel = L10n.Logout.buttonTitle
        logoutButton.addAction(UIAction { [weak self] _ in self?.onLogoutTap?() }, for: .touchUpInside)
    }

    private func setupSortButton() {
        sortButton.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        sortButton.accessibilityLabel = L10n.Feed.sort
        sortButton.addAction(UIAction { [weak self] _ in self?.onSortTap?() }, for: .touchUpInside)
    }

    private func setupSearchField() {
        searchTextField.placeholder = L10n.Feed.searchPlaceholder
        searchTextField.borderStyle = .roundedRect
        searchTextField.autocapitalizationType = .none
        searchTextField.autocorrectionType = .no
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.returnKeyType = .search

        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = .systemBlue
        icon.contentMode = .center
        icon.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        searchTextField.leftView = icon
        searchTextField.leftViewMode = .always

        searchTextField.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.onSearchChange?(self.searchTextField.text ?? "")
            },
            for: .editingChanged
        )
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [logoutButton, searchTextField, sortButton])
        stack.axis = .horizontal
        stack.spacing = Theme.itemSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),

            searchTextField.heightAnchor.constraint(equalToConstant: 40),
            logoutButton.widthAnchor.constraint(equalToConstant: Theme.minTapSize),
            logoutButton.heightAnchor.constraint(equalToConstant: Theme.minTapSize),
            sortButton.widthAnchor.constraint(equalToConstant: Theme.minTapSize),
            sortButton.heightAnchor.constraint(equalToConstant: Theme.minTapSize)
        ])
    }
}
