@testable import WallaMarvel

final class APIClientSpy: APIClientProtocol {
    private(set) var requestCalled = false
    private(set) var lastRequest: (any APIRequest)?
    var resultProvider: ((any APIRequest) throws -> Any)?
    var error: Error?

    func request<T: Decodable>(_ request: any APIRequest) async throws -> T {
        requestCalled = true
        lastRequest = request
        if let error { throw error }
        if let result = try resultProvider?(request) as? T { return result }
        throw TestError.any
    }
}
