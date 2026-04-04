import Foundation
import UIKit

@MainActor
protocol ListCharactersPresenterProtocol: AnyObject {
    var ui: ListCharactersUI? { get set }
    func screenTitle() -> String
    func getCharacters() async
    func loadNextPage() async
    func retryNextPage() async
    func searchCharacters(name: String)
    func clearSearch()
    func character(at index: Int) -> Character?
}

@MainActor
protocol ListCharactersUI: AnyObject {
    func showLoading()
    func hideLoading()
    func update(characters: [CharacterCellViewModel])
    func appendCharacters(_ newCharacters: [CharacterCellViewModel])
    func showPaginationLoading()
    func hidePaginationLoading()
    func showError(_ error: AppError)
    func showPaginationError(_ error: AppError)
    func showEmptySearch()
}

@MainActor
final class ListCharactersPresenter: ListCharactersPresenterProtocol {
    private enum Strings {
        static let screenTitle = "List of Characters"
    }

    var ui: ListCharactersUI?
    private let getCharactersUseCase: GetCharactersUseCaseProtocol

    private var currentPage = 1
    private var hasNextPage = false
    private var isLoadingPage = false
    private var isPaginationBlocked = false
    private var allCharacters: [Character] = []
    private var displayedCharacters: [Character] = []
    private var isSearchActive = false

    init(getCharactersUseCase: GetCharactersUseCaseProtocol) {
        self.getCharactersUseCase = getCharactersUseCase
    }

    func screenTitle() -> String {
        Strings.screenTitle
    }

    func character(at index: Int) -> Character? {
        guard index < displayedCharacters.count else { return nil }
        return displayedCharacters[index]
    }

    func getCharacters() async {
        ui?.showLoading()
        currentPage = 1
        hasNextPage = false
        isLoadingPage = false
        isPaginationBlocked = false
        isSearchActive = false
        allCharacters = []
        displayedCharacters = []

        do {
            let page = try await getCharactersUseCase.execute(page: currentPage)
            hasNextPage = page.hasNextPage
            allCharacters = page.characters
            displayedCharacters = allCharacters
            ui?.hideLoading()
            ui?.update(characters: map(allCharacters))
        } catch let error as AppError {
            ui?.hideLoading()
            ui?.showError(error)
        } catch {
            ui?.hideLoading()
            ui?.showError(AppErrorMapper.map(error))
        }
    }

    func loadNextPage() async {
        guard !isLoadingPage, hasNextPage, !isPaginationBlocked, !isSearchActive else { return }

        isLoadingPage = true
        ui?.showPaginationLoading()

        do {
            let page = try await getCharactersUseCase.execute(page: currentPage + 1)
            currentPage += 1
            hasNextPage = page.hasNextPage
            allCharacters.append(contentsOf: page.characters)
            displayedCharacters = allCharacters
            ui?.appendCharacters(map(page.characters))
        } catch let error as AppError {
            isPaginationBlocked = true
            ui?.showPaginationError(error)
        } catch {
            isPaginationBlocked = true
            ui?.showPaginationError(AppErrorMapper.map(error))
        }

        ui?.hidePaginationLoading()
        isLoadingPage = false
    }

    func retryNextPage() async {
        isPaginationBlocked = false
        await loadNextPage()
    }

    func searchCharacters(name: String) {
        let query = name.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
            clearSearch()
            return
        }
        isSearchActive = true
        let filtered = allCharacters.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
        displayedCharacters = filtered
        if filtered.isEmpty {
            ui?.showEmptySearch()
        } else {
            ui?.update(characters: map(filtered))
        }
    }

    func clearSearch() {
        isSearchActive = false
        displayedCharacters = allCharacters
        ui?.update(characters: map(allCharacters))
    }

    // MARK: - Private

    private func map(_ characters: [Character]) -> [CharacterCellViewModel] {
        characters.map { map($0) }
    }

    private func map(_ character: Character) -> CharacterCellViewModel {
        let (statusText, statusColor): (String, UIColor) = {
            switch character.status.lowercased() {
            case "alive": return ("Alive", .systemGreen)
            case "dead":  return ("Dead", .systemRed)
            default:      return ("Unknown", .systemGray)
            }
        }()
        return CharacterCellViewModel(
            name: character.name,
            species: character.species,
            imageURL: URL(string: character.imageURL),
            statusText: statusText,
            statusColor: statusColor
        )
    }
}
