# Backlog & Improvements
## Permissions and UX
- [ ] Move BLE permission request to a user action
	- Add a "Connect device" CTA on the home screen
	- Trigger permission checks only after the CTA
	- Show a compact explanation dialog when permissions are denied
	- Store a flag that permissions were already requested

## Theming and Design Tokens
- [ ] Replace magic constants with a theme config
	- Create spacing, radius, and typography tokens
	- Centralize colors and semantic styles
	- Update widgets to consume tokens instead of literals

## Localization
- [ ] Add localization with translations
	- Set up Flutter localization dependencies and config
	- Extract hardcoded strings to ARB files
	- Add at least one secondary language
	- Provide a fallback for missing keys

## Splash and Bootstrap
- [ ] Add splash screen with initialization flow
	- Use native splash or a dedicated Flutter splash screen
	- Load DI and services before showing home
	- Add a minimal loading indicator and error state

## Offline Storage
- [ ] Replace current storage with a more efficient solution
	- Evaluate Hive or other solutions for offline queue and history
	- Add a migration path from SharedPreferences
	- Persist readings with indexes by timestamp
	- Add clear/purge API for old data

## Models and Codegen
- [ ] Introduce code generation for models
	- Pick a tool (freezed, equatable, or similar)
	- Add JSON serialization support
	- Update BloodPressureReading and other models
	- Add copyWith/equals tests

## Service Interfaces
- [ ] Split services into interfaces and implementations
	- Define abstract interfaces for BLE, Sync, Storage
	- Register implementations in DI
	- Update call sites to depend on interfaces

## Real Sync Backend
- [ ] Upload BP readings to a real API
	- Add a REST client (dio or http)
	- Define DTOs and error handling
	- Implement retry with backoff
	- Add tests for happy and failure paths

## Android Background BLE
- [ ] Validate Android background BLE handling
	- Follow flutter_blue_plus guidance
	- Confirm required permissions and foreground service
	- Add a background-friendly reconnection strategy
	- Document device-specific caveats
