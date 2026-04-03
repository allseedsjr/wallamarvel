import Foundation

@MainActor
protocol DetailCharacterPresenterProtocol: AnyObject {
    var ui: DetailCharacterUI? { get set }
    func loadEpisode() async
}

@MainActor
protocol DetailCharacterUI: AnyObject {
    func showEpisodeLoading()
    func showEpisode(_ episode: Episode)
    func showEpisodeError(_ error: AppError)
}

@MainActor
final class DetailCharacterPresenter: DetailCharacterPresenterProtocol {
    var ui: DetailCharacterUI?
    private let character: Character
    private let getFirstEpisodeUseCase: GetCharacterFirstEpisodeUseCaseProtocol
    private var isLoadingEpisode = false

    init(
        character: Character,
        getFirstEpisodeUseCase: GetCharacterFirstEpisodeUseCaseProtocol = GetCharacterFirstEpisode()
    ) {
        self.character = character
        self.getFirstEpisodeUseCase = getFirstEpisodeUseCase
    }

    func loadEpisode() async {
        guard let episodeURL = character.firstEpisodeURL else { return }
        guard !isLoadingEpisode else { return }
        isLoadingEpisode = true
        ui?.showEpisodeLoading()
        do {
            let episode = try await getFirstEpisodeUseCase.execute(episodeURL: episodeURL)
            isLoadingEpisode = false
            ui?.showEpisode(episode)
        } catch let error as AppError {
            isLoadingEpisode = false
            ui?.showEpisodeError(error)
        } catch {
            isLoadingEpisode = false
            ui?.showEpisodeError(AppErrorMapper.map(error))
        }
    }
}
