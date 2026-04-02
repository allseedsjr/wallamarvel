import Foundation

protocol ListHeroesPresenterProtocol: AnyObject {
    var ui: ListHeroesUI? { get set }
    func screenTitle() -> String
    func getHeroes() async
}

protocol ListHeroesUI: AnyObject {
    func update(heroes: [Character])
}

final class ListHeroesPresenter: ListHeroesPresenterProtocol {
    var ui: ListHeroesUI?
    private let getHeroesUseCase: GetHeroesUseCaseProtocol
    
    init(getHeroesUseCase: GetHeroesUseCaseProtocol = GetHeroes()) {
        self.getHeroesUseCase = getHeroesUseCase
    }
    
    func screenTitle() -> String {
        "List of Heroes"
    }
    
    // MARK: UseCases
    
    func getHeroes() async {
        do {
            let heroes = try await getHeroesUseCase.execute()
            await MainActor.run {
                self.ui?.update(heroes: heroes)
            }
        } catch {
            print("Error fetching heroes: \(error)")
        }
    }
}
