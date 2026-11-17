import Foundation

extension Sequence {

    /// Убирает элементы с повторяющимся идентификатором (оставляет первый).
    /// Нужно, потому что diffable data source падает при дублях id.
    func uniqued<ID: Hashable>(by keyPath: KeyPath<Element, ID>) -> [Element] {
        var seen = Set<ID>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}
