import Foundation

struct GetCharactersRequest: APIRequest {
    let page: Int

    func makeURL() throws -> URL {
        var components = URLComponents(string: APIEndpoint.baseURL + APIEndpoint.Path.characters.rawValue)
        components?.queryItems = [URLQueryItem(name: "page", value: String(page))]
        guard let url = components?.url else {
            throw AppError.invalidData("Invalid characters endpoint URL")
        }
        return url
    }
}
