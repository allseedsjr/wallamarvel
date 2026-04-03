import Foundation

protocol APIRequest {
    func makeURL() throws -> URL
}
