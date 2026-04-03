import Foundation

protocol ListCharactersPresenterProtocol: AnyObject {
    var ui: ListCharactersUI? { get set }
    func screenTitle() -> String
    func getCharacters() async
}

@MainActor
protocol ListCharactersUI: AnyObject {
    func showLoading()
    func hideLoading()
    func update(characters: [Character])
    func showError(_ error: AppError)
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
    
    func getCharacters() async {
        await ui?.showLoading()
        
        do {
            let characters = try await getCharactersUseCase.execute()
            await ui?.update(characters: characters)
        } catch let error as AppError {
            await ui?.showError(error)
        } catch {
            let appError = AppErrorMapper.map(error)
            await ui?.showError(appError)
        }
    }
}
