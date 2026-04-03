import Foundation

struct GetEpisodeRequest: APIRequest {
    let urlString: String

    func makeURL() throws -> URL {
        guard let url = URL(string: urlString) else {
            throw AppError.invalidData("Invalid episode URL: \(urlString)")
        }
        return url
    }
}
