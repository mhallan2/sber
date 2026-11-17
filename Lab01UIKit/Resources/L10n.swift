import Foundation

/// Все пользовательские строки в одном месте.
/// Ключи собираются Xcode в String Catalog (File ▸ New ▸ String Catalog ▸ Localizable),
/// `defaultValue` используется, пока перевода нет.
nonisolated enum L10n {

    nonisolated enum Common {
        static var ok: String { String(localized: "common.ok", defaultValue: "OK") }
        static var cancel: String { String(localized: "common.cancel", defaultValue: "Отмена") }
        static var error: String { String(localized: "common.error", defaultValue: "Ошибка") }
    }

    nonisolated enum Auth {
        static var alertTitle: String { String(localized: "auth.alertTitle", defaultValue: "Авторизация") }
        static var usernamePlaceholder: String { String(localized: "auth.username", defaultValue: "Логин") }
        static var passwordPlaceholder: String { String(localized: "auth.password", defaultValue: "Пароль") }
        static var signIn: String { String(localized: "auth.signIn", defaultValue: "Войти") }
        static var signUp: String { String(localized: "auth.signUp", defaultValue: "Зарегистрироваться") }
        static var emptyCredentials: String { String(localized: "auth.emptyCredentials", defaultValue: "Заполните логин и пароль") }
        static var invalidCredentials: String { String(localized: "auth.invalidCredentials", defaultValue: "Неверный логин или пароль") }
        static var storageFailure: String { String(localized: "auth.storageFailure", defaultValue: "Не удалось сохранить данные") }
    }

    nonisolated enum Logout {
        static var title: String { String(localized: "logout.title", defaultValue: "Выход") }
        static var message: String { String(localized: "logout.message", defaultValue: "Сохранить данные для следующего входа?") }
        static var keep: String { String(localized: "logout.keep", defaultValue: "Сохранить данные") }
        static var delete: String { String(localized: "logout.delete", defaultValue: "Удалить данные") }
        static var deleteFailed: String { String(localized: "logout.deleteFailed", defaultValue: "Не удалось удалить данные") }
        static var buttonTitle: String { String(localized: "logout.button", defaultValue: "Выйти") }
    }

    nonisolated enum Loading {
        static var inProgress: String { String(localized: "loading.inProgress", defaultValue: "Загружаем данные...") }
        static var retry: String { String(localized: "loading.retry", defaultValue: "Повторить попытку") }
        static func failed(reason: String) -> String {
            String(localized: "loading.failed", defaultValue: "Не удалось загрузить данные.\n\nПричина: \(reason)")
        }
        static var offline: String { String(localized: "loading.offline", defaultValue: "Нет подключения к интернету.") }
        static var timedOut: String { String(localized: "loading.timedOut", defaultValue: "Превышено время ожидания ответа от сервера.") }
        static var hostNotFound: String { String(localized: "loading.hostNotFound", defaultValue: "Не удалось найти сервер.") }
        static var cannotConnect: String { String(localized: "loading.cannotConnect", defaultValue: "Не удалось подключиться к серверу.") }
    }

    nonisolated enum Network {
        static var invalidResponse: String { String(localized: "network.invalidResponse", defaultValue: "Сервер вернул некорректный ответ.") }
        static func httpError(_ code: Int) -> String {
            String(localized: "network.httpError", defaultValue: "Ошибка сервера. HTTP-код: \(code).")
        }
    }

    nonisolated enum Feed {
        static var title: String { String(localized: "feed.title", defaultValue: "Главная") }
        static var searchPlaceholder: String { String(localized: "feed.search", defaultValue: "Поиск пользователей") }
        static var usersSection: String { String(localized: "feed.users", defaultValue: "Пользователи") }
        static var postsSection: String { String(localized: "feed.posts", defaultValue: "Публикации") }
        static var unknownAuthor: String { String(localized: "feed.unknownAuthor", defaultValue: "Неизвестный автор") }
        static func postNumber(_ id: Int) -> String {
            String(localized: "feed.postNumber", defaultValue: "Пост №\(id)")
        }
        static var like: String { String(localized: "feed.like", defaultValue: "Нравится") }
        static var unlike: String { String(localized: "feed.unlike", defaultValue: "Убрать отметку «Нравится»") }
        static var sort: String { String(localized: "feed.sort", defaultValue: "Сортировка") }
        static var sortAscending: String { String(localized: "feed.sort.asc", defaultValue: "По возрастанию") }
        static var sortDescending: String { String(localized: "feed.sort.desc", defaultValue: "По убыванию") }
    }
}
