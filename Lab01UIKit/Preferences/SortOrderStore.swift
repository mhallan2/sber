import Foundation

protocol SortOrderStoring: AnyObject {
    var isAscending: Bool { get set }
}

/// Направление сортировки постов. Сохраняется локально и используется при повторном входе (по ТЗ).
final class SortOrderStore: SortOrderStoring {

    private let store: KeyValueStore

    init(store: KeyValueStore) {
        self.store = store
    }

    var isAscending: Bool {
        get { store.value(forKey: .isAscendingSort) ?? true }
        set { store.setValue(newValue, forKey: .isAscendingSort) }
    }
}
