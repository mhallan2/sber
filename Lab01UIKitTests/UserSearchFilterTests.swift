import Testing
@testable import Lab01UIKit

struct UserSearchFilterTests {

    @Test func emptyQueryReturnsEveryone() {
        #expect(UserSearchFilter.filter(TestData.users, query: "  ").count == 2)
    }

    @Test func matchesNameCaseInsensitively() {
        let result = UserSearchFilter.filter(TestData.users, query: "leanne")
        #expect(result.map(\.id) == [1])
    }

    @Test func matchesEmail() {
        let result = UserSearchFilter.filter(TestData.users, query: "melissa")
        #expect(result.map(\.id) == [2])
    }

    @Test func atPrefixSearchesOnlyUsernames() {
        // «Graham» есть в имени, но не в username → с «@» не находится.
        #expect(UserSearchFilter.filter(TestData.users, query: "@graham").isEmpty)
        #expect(UserSearchFilter.filter(TestData.users, query: "@bret").map(\.id) == [1])
    }
}
