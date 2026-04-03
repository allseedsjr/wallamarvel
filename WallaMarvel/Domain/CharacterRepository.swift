import Foundation

protocol CharacterRepositoryProtocol {
    func getCharacters() async throws -> [Character]
}

final class CharacterRepository: CharacterRepositoryProtocol {
    private let dataSource: CharacterDataSourceProtocol
    
    init(dataSource: CharacterDataSourceProtocol = CharacterDataSource()) {
        self.dataSource = dataSource
    }
    
    func getCharacters() async throws -> [Character] {
        do {
            let container = try await dataSource.getCharacters()
            return try container.toDomainCharacters()
        } catch let error as AppError {
            throw error
        } catch {
            throw AppErrorMapper.map(error)
        }
    }
}
