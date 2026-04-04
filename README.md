# WallaMarvel
iOS application that consumes the [Rick and Morty API](https://rickandmortyapi.com/) to list and display character details from the series.

## Product Board & PRD

Before writing a single line of code, a **Product Requirements Document (PRD)** and a **task board** were created on Notion. This practice is essential for working with product thinking: it forces clarity on what needs to be built and why, establishes acceptance criteria upfront, and makes it possible to break a product vision down into well-scoped, trackable tasks. The result is a development process that is easier to follow, review, and communicate — whether working solo or in a team.

 [View the board and PRD on Notion](https://www.notion.so/allseeds/336fa830e32e80029418d0d2a250275b?v=336fa830e32e8039a643000ce65afc45&source=copy_link)

## Overview
The project was iteratively evolved from a legacy codebase, focusing on code quality, clean architecture, testability, and user experience — including full accessibility support.


## Architecture
The app follows **Clean Architecture** principles with a clear separation between layers:
```
Domain      → Entities, Repositories (protocols), Use Cases
Data        → Repository implementations, DataSources, APIClient, Requests, Mapping
Presentation → ViewControllers, Presenters, Coordinators, Views
```

Principles applied throughout the project:
- **SOLID** — especially SRP, OCP and DIP (dependency inversion via protocols)
- **DRY** — no logic duplication across layers
- **Dependency Injection** — all `init`s receive dependencies explicitly; no concrete instances are created internally

## Evolution History

### Starting Point — Received Codebase

The project was received with **Marvel API** integration via `URLSession`, using **SPM** with Kingfisher as the only dependency. The initial structure already included `MarvelDataSource`, `MarvelRepository`, `GetHeroes` and the `ListHeroes` screens. Presentation files were moved into a `Presentation/` folder as the first action.

### WP-01 — API Migration and Test Infrastructure

- Migration from Marvel API to the **Rick and Morty API**
- Refactoring of `APIClient`
- Added data models: `Location`, `Origin`, `PageInfo`
- Created complete test infrastructure:
  - `APIClientTests` with `URLProtocolStub` to intercept requests without real network
  - Fixtures for all data models
  - Spies: `APIClientSpy`, `MarvelDataSourceSpy`, `MarvelRepositorySpy`, `GetHeroesUseCaseSpy`, `ListHeroesUISpy`
  - Tests for `APIClient`, `MarvelDataSource`, `MarvelRepository`, `GetHeroes` and `ListHeroesPresenter`
  - `TestError` and `URLProtocolStub` as test utilities

### WP-07 — Domain Separation and Renaming

**Data layer improvement:**
- Created the `Character` domain entity
- Created `CharacterDataModel+Mapping` to convert `CharacterDataModel` → `Character`
- Mapping tests with `CharacterDataModelMappingTests`
- `Character+fixture`

**Renaming to reflect the correct domain:**
- `MarvelDataSource` → `CharacterDataSource`
- `MarvelRepository` → `CharacterRepository`
- `GetHeroes` → `GetCharacters`
- Folder `List Heroes` → `ListCharacter`
- All tests and spies renamed accordingly

### WP-08 — Centralized Error Handling
- Created `AppError` — typed enum with cases: `.network`, `.invalidData`, `.unknown`
- Created `AppErrorMapper` — converts generic errors into `AppError`
- Typed error propagation across all layers: `CharacterDataSource` → `CharacterRepository` → `ListCharactersPresenter` → UI
- Error UI on the list screen: message label + retry button
- Tests: `AppErrorTests`, `AppErrorMapperTests`, error scenarios in `ListCharactersPresenterTests` and `CharacterDataSourceTests`

### WP-04 — Coordinator Pattern
- Introduced the Coordinator pattern to decouple navigation from ViewControllers
- `AppCoordinator`, `NavigationCoordinator`, `ListCharactersCoordinator`, `DetailCharacterCoordinator`
- `SceneDelegate` updated to start the flow via `AppCoordinator`
- Initial stub for `DetailCharacterViewController`
- Tests: `AppCoordinatorTests`, `NavigationCoordinatorTests`, `ListCharactersCoordinatorTests`, `DetailCharacterCoordinatorTests`
- Spies: `CoordinatorSpy`, `NavigationControllerSpy`, `ListCharactersPresenterSpy`

### WP-10 — APIClient with APIRequest Pattern
- Introduced `APIRequest` protocol to encapsulate URL construction per endpoint
- Created `APIEndpoint` and `GetCharactersRequest`
- `APIClient` refactored to be generic, accepting any `APIRequest`
- Removed unused `String+MD5` helper
- `APIClientTests` significantly expanded
- `GetCharactersRequestTests` — validates host, scheme and query parameters
- `APIClientSpy` updated to track the received request

### WP-02 — Pagination and Resilience
- `CharactersPage` encapsulates the character list and `hasNextPage`
- `ListCharactersPresenter` manages pagination state: `currentPage`, `hasNextPage`, `isLoadingPage`, `isPaginationBlocked`
- Infinite scroll via `UITableViewDelegate.willDisplay`
- Pagination loading footer in `UITableView`
- Pagination error with `UIAlertController`: **Retry** and **Dismiss** buttons
- `retryNextPage()` unblocks and retries without resetting the current list
- Tests: full pagination coverage (success, error, retry, blocking, page accumulation)

### WP-03 — Detail Screen
- `Episode` entity with `id`, `name`, `airDate`, `code`
- `EpisodeDataSource`, `EpisodeRepository`, `GetCharacterFirstEpisode` and `GetEpisodeRequest` following the same pattern as other layers
- `Character` extended with `type` and `firstEpisodeURL`
- `CharacterDataModel+Mapping` updated to map the new fields
- `DetailCharacterPresenter` with `DetailCharacterUI` protocol — 3 states for the episode section: loading, success, error + retry
- `DetailCharacterViewController`: scroll view, circular image (Kingfisher with cache), status badge, info rows, episode section with retry
- Removed default parameters from all `init`s — dependency graph moved exclusively to `SceneDelegate` and `ListCharactersCoordinator`
- Tests: `EpisodeDataSourceTests`, `EpisodeRepositoryTests`, `GetCharacterFirstEpisodeTests`, `DetailCharacterPresenterTests`
- Fixtures: `Episode+fixture`, `EpisodeDataModel+fixture`
- Spies: `EpisodeDataSourceSpy`, `EpisodeRepositorySpy`, `GetCharacterFirstEpisodeUseCaseSpy`, `DetailCharacterPresenterSpy`, `DetailCharacterUISpy`

### WP-12 — Code Improvement: Magic Numbers to Constants
- Numeric constants and string literals moved to `private enum Constants` and `private enum Strings`
- Applied to: `DetailCharacterViewController`, `ListCharactersPresenter`, `ListCharactersTableView`, `ListCharactersTableViewCell`, `ListCharactersViewController`

### WP-09 — Accessibility (VoiceOver)
**`ListCharactersTableViewCell`:**
- Cell marked as the single accessible element (`isAccessibilityElement = true`)
- Image and name label marked as non-accessible
- Composed `accessibilityLabel`: `"Character: <name>."`
- `accessibilityHint`: `"Double tap to see more details"`
- `trailingAnchor` added to the name label — fixes horizontal overflow and enables line wrapping

**`DetailCharacterViewController`:**
- Character image marked as non-accessible (`isAccessibilityElement = false`)
- Status badge `accessibilityLabel` without the bullet `●`: `"Status: Alive"` / `"Status: Dead"` / `"Status: Unknown"`
- Each info row (`UIStackView`) marked as the single accessible element with a composed label: `"Species: Human"`, `"Gender: Male"`, etc.
- Episode section with a composed `accessibilityLabel` once loaded

**Error states (both screens):**
- `UIAccessibility.post(notification: .screenChanged)` when showing an error, automatically moving VoiceOver focus to the error message
- Retry buttons with descriptive `accessibilityHint`

### WP-13 — Search Bar with Local Filter
- `UISearchController` added to the `navigationItem` of the list screen
- 500ms debounce via cancellable `Task`
- Local filter over characters already loaded in memory — no new API request
- `allCharacters` accumulates all loaded characters, including subsequent pages
- `isSearchActive` blocks pagination while search is active
- Case-insensitive search with `localizedCaseInsensitiveContains`
- Empty string or whitespace-only input restores the full list
- Cancelling search restores the list immediately
- Empty state when no results are found: icon, title and message
- Empty state with composed `accessibilityLabel` and `UIAccessibility.screenChanged`
- Search bar strings moved to `private enum Strings`
- 7 new presenter tests; `ListCharactersPresenterSpy` and `ListCharactersUISpy` updated

### WP-11 — Splash Screen
- `LaunchScreen.storyboard` updated — it was blank since the initial commit
- Dark blue background (`#0B1120`)
- Title `"WallaMarvel"` — bold 36pt, white, centered
- Subtitle `"Rick & Morty Characters"` — 16pt, green `#97CE4C`, centered
- Layout via `UIStackView` with Auto Layout — no Swift code added

### WP-15 — Visual Polish: Placeholder and Circular Images
**`ListCharactersTableViewCell`:**
- Placeholder (`person.crop.circle.fill`) displayed while Kingfisher loads the character thumbnail, preventing empty space during network requests
- `contentMode = .scaleAspectFill` and `clipsToBounds = true` applied to the image view for correct cropping inside the fixed frame
- Circular corner radius (`40pt` — half of the 80pt image size), consistent with the style already used on the detail screen
- `placeholderImage` and `accessibilityHint` string literals moved to `private enum Strings`, completing the Constants/Strings enum discipline applied in WP-12

## Technical Decisions
### Local filter vs. API search
The search bar filters characters already loaded in memory instead of making a new API request on each keystroke. Since the app already paginates and accumulates all characters in `allCharacters`, querying the network again would be wasteful and would add latency with no real benefit for the user.

### Cancellable `Task` for debounce instead of Combine
A 500ms debounce was implemented by cancelling and recreating a `Task` on each keystroke. This avoids introducing Combine or third-party libraries for a single use case. Swift Concurrency is already used throughout the app, so this keeps the stack consistent and the solution readable.

### Composition Root in `SceneDelegate`
All concrete dependency instantiation happens exclusively in `SceneDelegate` and `ListCharactersCoordinator`. No layer creates its own dependencies internally. This makes the dependency graph explicit, visible in one place, and straightforward to swap in tests.

### Removing default parameters from all `init`s
Default parameters on `init`s were removed across DataSources, Repositories, UseCases and Presenters. Even though they look convenient, they hide the dependency graph — the compiler accepts incomplete wiring silently. Making every dependency explicit forces correctness at the call site and improves testability.

### `APIRequest` protocol for URL construction
Each endpoint owns its URL building logic via a dedicated `APIRequest` struct. The `APIClient` is fully generic and knows nothing about specific endpoints. Adding a new request is a matter of creating a new struct — no changes to `APIClient` needed.

### Spies over Mocks
Test doubles are implemented as Spies (recording calls and parameters) rather than Mocks (with built-in assertions). Spies keep test doubles simple and reusable across multiple test cases, while keeping assertions in the test itself — which is where they belong.

### `UIAccessibility.post(.screenChanged)` for errors
When an error state appears, `.screenChanged` is posted instead of `.announcement`. The difference is meaningful: `.announcement` speaks a string but leaves focus where it is, which can confuse VoiceOver users. `.screenChanged` moves focus to the error element, making the new context explicit — which is the correct behaviour for a full-screen state change.

### Accessibility labels in the View layer
`accessibilityLabel` composition (e.g. `"Character: Morty Smith."`) is intentionally kept in the View layer. These strings are UI and platform conventions, not business rules — there is no logic to test and no reason to involve the Presenter.

## Test Coverage
Patterns used:
- **Spy** — verifies behavior (calls, parameters)
- **Stub** — controls return values
- **Fixture** — builds models with sensible default values via optional parameters
- **URLProtocolStub** — intercepts `URLSession` requests without real network

Layers covered:
- `APIClient`, `GetCharactersRequest`
- `CharacterDataSource`, `EpisodeDataSource`
- `CharacterRepository`, `EpisodeRepository`
- `GetCharacters`, `GetCharacterFirstEpisode`
- `CharacterDataModel+Mapping`
- `AppError`, `AppErrorMapper`
- `ListCharactersPresenter`, `DetailCharacterPresenter`
- `AppCoordinator`, `NavigationCoordinator`, `ListCharactersCoordinator`, `DetailCharacterCoordinator`

## Technologies
| Technology | Usage |
|---|---|
| Swift | Main language |
| UIKit | Programmatic UI |
| Swift Concurrency (`async/await`, `Task`) | Async calls and debounce |
| URLSession | Networking layer |
| Kingfisher (SPM) | Image loading and caching |
| XCTest | Unit tests |

## Folder Structure
```
WallaMarvel/
├── AppDelegate.swift
├── SceneDelegate.swift          ← Composition Root
├── Data/
│   ├── APIClient.swift
│   ├── CharacterDataSource.swift
│   ├── EpisodeDataSource.swift
│   ├── DataModel/               ← Decodable models
│   ├── Mapping/                 ← DataModel → Domain
│   ├── ErrorMapping/            ← Error → AppError
│   └── Requests/                ← APIRequest implementations
├── Domain/
│   ├── Entities/                ← Character, Episode
│   ├── Errors/                  ← AppError
│   ├── UseCases/                ← GetCharacters, GetCharacterFirstEpisode
│   ├── CharacterRepository.swift
│   └── EpisodeRepository.swift
└── Presentation/
    ├── Coordinators/            ← App, Navigation, List, Detail
    └── ListCharacter/
        ├── ListCharactersViewController.swift
        ├── ListCharactersPresenter.swift
        ├── ListCharactersTableView.swift
        ├── ListCharactersTableViewCell.swift
        ├── ListCharactersAdapter.swift
        └── DetailCharacter/
            ├── DetailCharacterViewController.swift
            └── DetailCharacterPresenter.swift
```
