import Foundation

protocol CharacterRepositoryProtocol {
    func getCharacters(page: Int) async throws -> CharactersPage
}

final class CharacterRepository: CharacterRepositoryProtocol {
    private let dataSource: CharacterDataSourceProtocol
    
    init(dataSource: CharacterDataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    func getCharacters(page: Int) async throws -> CharactersPage {
        do {
            let container = try await dataSource.getCharacters(page: page)
            let characters = try container.toDomainCharacters()
            return CharactersPage(characters: characters, hasNextPage: container.info.next != nil)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppErrorMapper.map(error)
        }
    }
}
