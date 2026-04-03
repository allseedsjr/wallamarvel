import Foundation

protocol APIClientProtocol {
    func getCharacters(page: Int) async throws -> CharacterDataContainer
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let maxRetries: Int
    private let retryDelay: UInt64

    init(
        session: URLSession = URLSession.shared,
        maxRetries: Int = 3,
        retryDelay: UInt64 = 1_000_000_000
    ) {
        self.session = session
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
    }

    func getCharacters(page: Int) async throws -> CharacterDataContainer {
        var components = URLComponents(string: "https://rickandmortyapi.com/api/character")
        components?.queryItems = [URLQueryItem(name: "page", value: String(page))]

        guard let url = components?.url else {
            throw AppError.invalidData("Invalid API endpoint URL")
        }

        var lastError: Error?
        for attempt in 1...maxRetries {
            do {
                let (data, response) = try await session.data(from: url)

                if let httpResponse = response as? HTTPURLResponse {
                    guard (200...299).contains(httpResponse.statusCode) else {
                        throw AppError.network("HTTP \(httpResponse.statusCode): Server error")
                    }
                }

                return try JSONDecoder().decode(CharacterDataContainer.self, from: data)
            } catch {
                lastError = error
                if attempt < maxRetries {
                    try? await Task.sleep(nanoseconds: UInt64(attempt) * retryDelay)
                }
            }
        }

        throw lastError!
    }
}
