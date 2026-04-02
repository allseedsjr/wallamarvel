import Foundation

protocol ListCharactersPresenterProtocol: AnyObject {
    var ui: ListCharactersUI? { get set }
    func screenTitle() -> String
    func getCharacters() async
}

protocol ListCharactersUI: AnyObject {
    func update(characters: [Character])
}

final class ListCharactersPresenter: ListCharactersPresenterProtocol {
    var ui: ListCharactersUI?
    private let getCharactersUseCase: GetCharactersUseCaseProtocol
    
    init(getCharactersUseCase: GetCharactersUseCaseProtocol = GetCharacters()) {
        self.getCharactersUseCase = getCharactersUseCase
    }
    
    func screenTitle() -> String {
        "List of Characters"
    }
    
    // MARK: UseCases
    
    func getCharacters() async {
        do {
            let characters = try await getCharactersUseCase.execute()
            await MainActor.run {
                self.ui?.update(characters: characters)
            }
        } catch {
            print("Error fetching characters: \(error)")
        }
    }
}
