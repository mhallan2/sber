import Foundation

/// Чистая функция поиска пользователей — легко тестировать без UI.
/// Запрос вида `@bret` ищет только по username, остальные — по имени, username и email.
nonisolated enum UserSearchFilter {

    static func filter(_ users: [User], query rawQuery: String) -> [User] {
        let query = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return users
        }

        if query.hasPrefix("@") {
            let usernameQuery = String(query.dropFirst())
            return users.filter { $0.username.localizedCaseInsensitiveContains(usernameQuery) }
        }

        return users.filter { user in
            user.name.localizedCaseInsensitiveContains(query) ||
            user.username.localizedCaseInsensitiveContains(query) ||
            user.email.localizedCaseInsensitiveContains(query)
        }
    }
}
