import Foundation

/// Composition root: единственное место, где создаются и связываются реализации.
/// Вместо `AuthService.shared` / `APIService.shared` зависимости передаются явно,
/// поэтому в тестах их можно подменить.
final class AppDependencies {

    let keyValueStore: KeyValueStore
    let secureStore: SecureStore
    let authService: AuthServicing
    let sessionCleaner: SessionCleaning
    let feedRepository: FeedRepository
    let likesStore: LikesStoring
    let sortOrderStore: SortOrderStoring

    init(
        keyValueStore: KeyValueStore = UserDefaultsStore(),
        secureStore: SecureStore = KeychainStore(),
        feedRepository: FeedRepository = DefaultFeedRepository()
    ) {
        self.keyValueStore = keyValueStore
        self.secureStore = secureStore
        self.feedRepository = feedRepository

        self.authService = AuthService(keyValueStore: keyValueStore, secureStore: secureStore)
        self.sessionCleaner = SessionCleaner(secureStore: secureStore, keyValueStore: keyValueStore)
        self.likesStore = LikesStore(store: keyValueStore)
        self.sortOrderStore = SortOrderStore(store: keyValueStore)

        authService.removeLegacyCredentials()
    }

    /// У каждого экрана свой презентер: у него своё состояние `isPresenting`.
    func makeLogoutPresenter() -> LogoutPresenter {
        LogoutPresenter(sessionCleaner: sessionCleaner)
    }
}
