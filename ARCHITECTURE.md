# Lab01UIKit — архитектура

UIKit + лёгкий MVVM + Coordinator. Зависимости передаются явно (composition root — `AppDependencies`).

```
App/          точка входа, AppCoordinator (навигация), AppDependencies (сборка)
Core/         Networking (HTTPClient, Endpoint), Storage (Keychain, UserDefaults за протоколами),
              UI (Theme, переиспользуемые вью), Extensions
Domain/       Models, FeedRepository (два параллельных запроса), Auth (AuthService, SessionCleaner)
Preferences/  LikesStore, SortOrderStore (локальные настройки пользователя)
Features/     Auth, Loading, Feed — каждая: ViewController + ViewModel (+ View / DataSource / Layout)
Resources/    Assets, L10n (все строки)
```

## Поток
`Auth → Loading → Feed → (выход) → Auth`. Контроллеры сообщают о событиях делегатам
(`AuthViewControllerDelegate`, `LoadingViewControllerDelegate`, `FeedViewControllerDelegate`),
переходы выполняет только `AppCoordinator`.

## Правила
- ViewController: жизненный цикл и связывание. Логика — в ViewModel, вёрстка — в View/LayoutFactory.
- Сеть и декодирование — `nonisolated` (не на main actor). Хранилища и UI — main actor (по умолчанию в проекте).
- Все ключи хранилища — `StorageKey` / `SecureKey`. Всё, что стирается при выходе, — в `SessionCleaner`.
- Новые строки — только через `L10n`.
