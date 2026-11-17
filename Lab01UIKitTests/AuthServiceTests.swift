import Testing
@testable import Lab01UIKit

@MainActor
struct AuthServiceTests {

    private let keyValueStore = InMemoryKeyValueStore()
    private let secureStore = InMemorySecureStore()

    private func makeService() -> AuthService {
        AuthService(keyValueStore: keyValueStore, secureStore: secureStore)
    }

    @Test func registerThenLoginSucceeds() throws {
        let service = makeService()
        #expect(!service.hasRegisteredUser)

        try service.register(username: "lisa", password: "secret")
        #expect(service.hasRegisteredUser)
        try service.login(username: "lisa", password: "secret")
    }

    @Test func wrongPasswordIsRejected() throws {
        let service = makeService()
        try service.register(username: "lisa", password: "secret")

        #expect(throws: AuthError.self) {
            try service.login(username: "lisa", password: "wrong")
        }
    }

    @Test func emptyCredentialsAreRejected() {
        let service = makeService()
        #expect(throws: AuthError.self) {
            try service.register(username: "", password: "x")
        }
    }

    @Test func keychainFailureIsReportedAndNothingIsSaved() {
        secureStore.shouldFailOnSave = true
        let service = makeService()

        #expect(throws: AuthError.self) {
            try service.register(username: "lisa", password: "secret")
        }
        #expect(!service.hasRegisteredUser)
    }

    @Test func sessionCleanerRemovesEverything() throws {
        let service = makeService()
        let cleaner = SessionCleaner(secureStore: secureStore, keyValueStore: keyValueStore)
        let likes = LikesStore(store: keyValueStore)
        let sort = SortOrderStore(store: keyValueStore)

        try service.register(username: "lisa", password: "secret")
        likes.toggle(5)
        sort.isAscending = false

        try cleaner.clearAllLocalData()

        #expect(!service.hasRegisteredUser)
        #expect(!likes.isLiked(5))
        #expect(sort.isAscending == true)
    }
}
