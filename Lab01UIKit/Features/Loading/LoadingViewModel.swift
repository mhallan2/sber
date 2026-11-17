import Foundation

/// Состояние экрана загрузки одним `enum` вместо набора флагов
/// (`isLogoutAlertPresented`, `pendingLoadedData`, `loadingTask` и т. п.).
final class LoadingViewModel {

    enum State {
        case loading
        case failed(LoadingErrorInfo)
        case loaded(FeedContent)
    }

    var onStateChange: ((State) -> Void)?

    private(set) var state: State = .loading {
        didSet { onStateChange?(state) }
    }

    private let repository: FeedRepository
    private var loadingTask: Task<Void, Never>?

    init(repository: FeedRepository) {
        self.repository = repository
    }

    func load() {
        loadingTask?.cancel()
        state = .loading

        // Задача НЕ захватывает self до await: нет временного цикла self → task → self,
        // а при уничтожении модели результат просто игнорируется.
        loadingTask = Task { [weak self, repository] in
            let result: Result<FeedContent, Error>
            do {
                result = .success(try await repository.loadFeed())
            } catch {
                result = .failure(error)
            }

            guard !Task.isCancelled, let self else { return }
            self.loadingTask = nil

            switch result {
            case .success(let content):
                self.state = .loaded(content)
            case .failure(let error):
                self.state = .failed(LoadingErrorMapper.map(error))
            }
        }
    }

    func cancel() {
        loadingTask?.cancel()
        loadingTask = nil
    }
}
