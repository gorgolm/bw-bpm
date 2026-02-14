# Backlog & Improvements
- [ ] Request permissions at better time
- [ ] Avoid using magic constants - have a theme config for spaces, font sized and colors
- [ ] Add localization with text translations instead of hardcoded strings
- [ ] Add splashscreen with init stuff
- [ ] Use a better offline storage solution
- [ ] Use freezed, equitable or some other code generation for models
- [ ] Use interface + implementation for services - etc.

## Architecture
- [ ] **Dependency Injection:** Introduce `get_it` or `riverpod` for better service management.
- [ ] **Repository Pattern:** Abstract Hive implementation behind a clean domain repository interface.
- [ ] **State Management:** Use BLoC or Riverpod for UI state instead of `setState` and `ValueListenable`.

## Features
- [ ] **Real Backend:** Replace mock `SyncService` with actual REST/GraphQL client (`dio`).
- [ ] **User ID Filtering:** Filter BLE readings by specific User ID if multiple people use the same device.
- [ ] **Pairing UI:** Allow user to specifically select which device to pair with instead of auto-connect to any BP monitor.
- [ ] **Retry Logic:** Implement `workmanager` for periodic background sync tasks when internet returns.

## Quality Assurance
- [ ] **Unit Tests:** Test byte parsing logic for BLE.
- [ ] **Integration Tests:** Test full flow with mocked BLE interface.
- [ ] **Error Handling:** robust handling of BLE disconnects during transfer.
