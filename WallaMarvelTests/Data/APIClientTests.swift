import XCTest
@testable import WallaMarvel

final class APIClientTests: XCTestCase {
    private let targetURL = URL(string: "https://rickandmortyapi.com/api/character?page=1")!
    private var session: URLSession!

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        session = URLSession(configuration: configuration)
    }

    override func tearDown() {
        URLProtocolStub.stopIntercepting()
        session = nil
        super.tearDown()
    }

    // MARK: - URL passthrough

    func test_whenRequest_called_shouldUseURLFromRequest() async throws {
        var requestedURL: URL?
        let data = makeValidResponseData()
        let response = HTTPURLResponse(url: targetURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.startIntercepting(with: .init(data: data, response: response, error: nil, requestObserver: { request in
            requestedURL = request.url
        }))

        let sut = APIClient(session: session)
        let _: CharacterDataContainer = try await sut.request(TestAPIRequest(url: targetURL))

        XCTAssertEqual(requestedURL, targetURL)
    }

    // MARK: - Decoding

    func test_whenRequest_succeeds_shouldReturnDecodedModel() async throws {
        let data = makeValidResponseData()
        let response = HTTPURLResponse(url: targetURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.startIntercepting(with: .init(data: data, response: response, error: nil, requestObserver: nil))

        let sut = APIClient(session: session)
        let result: CharacterDataContainer = try await sut.request(TestAPIRequest(url: targetURL))

        XCTAssertEqual(result.results.count, 1)
    }

    // MARK: - Error handling

    func test_whenRequest_sessionReturnsError_shouldThrow() async {
        URLProtocolStub.startIntercepting(with: .init(data: nil, response: nil, error: TestError.any, requestObserver: nil))

        let sut = APIClient(session: session, maxRetries: 1, retryDelay: 0)

        do {
            let _: CharacterDataContainer = try await sut.request(TestAPIRequest(url: targetURL))
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func test_whenRequest_receivesInvalidData_shouldThrow() async {
        let response = HTTPURLResponse(url: targetURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.startIntercepting(with: .init(data: Data("invalid".utf8), response: response, error: nil, requestObserver: nil))

        let sut = APIClient(session: session, maxRetries: 1, retryDelay: 0)

        do {
            let _: CharacterDataContainer = try await sut.request(TestAPIRequest(url: targetURL))
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(true)
        }
    }

    // MARK: - Retry

    func test_whenRequest_failsOnFirstAttempt_shouldRetryAndSucceed() async throws {
        let successData = makeValidResponseData()
        let successResponse = HTTPURLResponse(url: targetURL, statusCode: 200, httpVersion: nil, headerFields: nil)

        URLProtocolStub.startIntercepting(withSequence: [
            .init(data: nil, response: nil, error: URLError(.networkConnectionLost), requestObserver: nil),
            .init(data: successData, response: successResponse, error: nil, requestObserver: nil)
        ])

        let sut = APIClient(session: session, maxRetries: 2, retryDelay: 0)
        let result: CharacterDataContainer = try await sut.request(TestAPIRequest(url: targetURL))

        XCTAssertEqual(result.results.count, 1)
    }

    func test_whenRequest_failsAllAttempts_shouldThrowLastError() async {
        var requestCount = 0
        URLProtocolStub.startIntercepting(withSequence: [
            .init(data: nil, response: nil, error: URLError(.networkConnectionLost), requestObserver: { _ in requestCount += 1 }),
            .init(data: nil, response: nil, error: URLError(.networkConnectionLost), requestObserver: { _ in requestCount += 1 }),
            .init(data: nil, response: nil, error: URLError(.networkConnectionLost), requestObserver: { _ in requestCount += 1 })
        ])

        let sut = APIClient(session: session, maxRetries: 3, retryDelay: 0)

        do {
            let _: CharacterDataContainer = try await sut.request(TestAPIRequest(url: targetURL))
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(requestCount, 3)
        }
    }

    func test_whenRequest_succeedsOnFirstAttempt_shouldNotRetry() async throws {
        var requestCount = 0
        let successData = makeValidResponseData()
        let successResponse = HTTPURLResponse(url: targetURL, statusCode: 200, httpVersion: nil, headerFields: nil)

        URLProtocolStub.startIntercepting(withSequence: [
            .init(data: successData, response: successResponse, error: nil, requestObserver: { _ in requestCount += 1 })
        ])

        let sut = APIClient(session: session, maxRetries: 3, retryDelay: 0)
        let _: CharacterDataContainer = try await sut.request(TestAPIRequest(url: targetURL))

        XCTAssertEqual(requestCount, 1)
    }

    // MARK: - Helpers

    private func makeValidResponseData() -> Data {
        let json = """
        {
            "info": {
                "count": 1,
                "pages": 1,
                "next": null,
                "prev": null
            },
            "results": [
                {
                    "id": 1,
                    "name": "Rick Sanchez",
                    "status": "Alive",
                    "species": "Human",
                    "type": "",
                    "gender": "Male",
                    "origin": {
                        "name": "Earth",
                        "url": "https://example.com/origin/1"
                    },
                    "location": {
                        "name": "Earth",
                        "url": "https://example.com/location/1"
                    },
                    "image": "https://example.com/character/1.png",
                    "episode": [
                        "https://example.com/episode/1"
                    ],
                    "url": "https://example.com/character/1",
                    "created": "2020-01-01T00:00:00.000Z"
                }
            ]
        }
        """
        return Data(json.utf8)
    }
}

// MARK: - Test helpers

private struct TestAPIRequest: APIRequest {
    let url: URL
    func makeURL() throws -> URL { url }
}

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        session = URLSession(configuration: configuration)
    }

    override func tearDown() {
        URLProtocolStub.stopIntercepting()
        session = nil
        super.tearDown()
    }

    // MARK: - URL passthrough

    func test_whenRequest_called_shouldUseProvidedURL() async throws {
        var requestedURL: URL?
        let data = makeValidResponseData()
        let response = HTTPURLResponse(url: targetURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.startIntercepting(with: .init(data: data, response: response, error: nil, requestObserver: { request in
            requestedURL = request.url
        }))

        let sut = APIClient(session: session)
        let _: CharacterDataContainer = try await sut.request(targetURL)

        XCTAssertEqual(requestedURL, targetURL)
    }

    // MARK: - Decoding

    func test_whenRequest_succeeds_shouldReturnDecodedModel() async throws {
        let data = makeValidResponseData()
        let response = HTTPURLResponse(url: targetURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.startIntercepting(with: .init(data: data, response: response, error: nil, requestObserver: nil))

        let sut = APIClient(session: session)
        let result: CharacterDataContainer = try await sut.request(targetURL)

        XCTAssertEqual(result.results.count, 1)
    }

    // MARK: - Error handling

    func test_whenRequest_sessionReturnsError_shouldThrow() async {
        URLProtocolStub.startIntercepting(with: .init(data: nil, response: nil, error: TestError.any, requestObserver: nil))

        let sut = APIClient(session: session, maxRetries: 1, retryDelay: 0)

        do {
            let _: CharacterDataContainer = try await sut.request(targetURL)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func test_whenRequest_receivesInvalidData_shouldThrow() async {
        let response = HTTPURLResponse(url: targetURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.startIntercepting(with: .init(data: Data("invalid".utf8), response: response, error: nil, requestObserver: nil))

        let sut = APIClient(session: session, maxRetries: 1, retryDelay: 0)

        do {
            let _: CharacterDataContainer = try await sut.request(targetURL)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(true)
        }
    }

    // MARK: - Retry

    func test_whenRequest_failsOnFirstAttempt_shouldRetryAndSucceed() async throws {
        let successData = makeValidResponseData()
        let successResponse = HTTPURLResponse(url: targetURL, statusCode: 200, httpVersion: nil, headerFields: nil)

        URLProtocolStub.startIntercepting(withSequence: [
            .init(data: nil, response: nil, error: URLError(.networkConnectionLost), requestObserver: nil),
            .init(data: successData, response: successResponse, error: nil, requestObserver: nil)
        ])

        let sut = APIClient(session: session, maxRetries: 2, retryDelay: 0)
        let result: CharacterDataContainer = try await sut.request(targetURL)

        XCTAssertEqual(result.results.count, 1)
    }

    func test_whenRequest_failsAllAttempts_shouldThrowLastError() async {
        var requestCount = 0
        URLProtocolStub.startIntercepting(withSequence: [
            .init(data: nil, response: nil, error: URLError(.networkConnectionLost), requestObserver: { _ in requestCount += 1 }),
            .init(data: nil, response: nil, error: URLError(.networkConnectionLost), requestObserver: { _ in requestCount += 1 }),
            .init(data: nil, response: nil, error: URLError(.networkConnectionLost), requestObserver: { _ in requestCount += 1 })
        ])

        let sut = APIClient(session: session, maxRetries: 3, retryDelay: 0)

        do {
            let _: CharacterDataContainer = try await sut.request(targetURL)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(requestCount, 3)
        }
    }

    func test_whenRequest_succeedsOnFirstAttempt_shouldNotRetry() async throws {
        var requestCount = 0
        let successData = makeValidResponseData()
        let successResponse = HTTPURLResponse(url: targetURL, statusCode: 200, httpVersion: nil, headerFields: nil)

        URLProtocolStub.startIntercepting(withSequence: [
            .init(data: successData, response: successResponse, error: nil, requestObserver: { _ in requestCount += 1 })
        ])

        let sut = APIClient(session: session, maxRetries: 3, retryDelay: 0)
        let _: CharacterDataContainer = try await sut.request(targetURL)

        XCTAssertEqual(requestCount, 1)
    }

    // MARK: - Helpers

    private func makeValidResponseData() -> Data {
        let json = """
        {
            "info": {
                "count": 1,
                "pages": 1,
                "next": null,
                "prev": null
            },
            "results": [
                {
                    "id": 1,
                    "name": "Rick Sanchez",
                    "status": "Alive",
                    "species": "Human",
                    "type": "",
                    "gender": "Male",
                    "origin": {
                        "name": "Earth",
                        "url": "https://example.com/origin/1"
                    },
                    "location": {
                        "name": "Earth",
                        "url": "https://example.com/location/1"
                    },
                    "image": "https://example.com/character/1.png",
                    "episode": [
                        "https://example.com/episode/1"
                    ],
                    "url": "https://example.com/character/1",
                    "created": "2020-01-01T00:00:00.000Z"
                }
            ]
        }
        """
        return Data(json.utf8)
    }
}

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        session = URLSession(configuration: configuration)
    }

    override func tearDown() {
        URLProtocolStub.stopIntercepting()
        session = nil
        super.tearDown()
    }

    func test_whenGetCharacters_called_shouldRequestCorrectBaseURL() async throws {
        var requestedURL: URL?
        let data = makeValidResponseData()
        let response = HTTPURLResponse(url: baseEndpoint!, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.startIntercepting(with: .init(data: data, response: response, error: nil, requestObserver: { request in
            requestedURL = request.url
        }))

        let sut = APIClient(session: session)
        _ = try await sut.getCharacters(page: 1)

        XCTAssertEqual(requestedURL?.host, "rickandmortyapi.com")
        XCTAssertEqual(requestedURL?.path, "/api/character")
    }

    func test_whenGetCharacters_called_shouldIncludePageQueryParameter() async throws {
        var requestedURL: URL?
        let data = makeValidResponseData()
        let response = HTTPURLResponse(url: baseEndpoint!, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.startIntercepting(with: .init(data: data, response: response, error: nil, requestObserver: { request in
            requestedURL = request.url
        }))

        let sut = APIClient(session: session)
        _ = try await sut.getCharacters(page: 3)

        let components = URLComponents(url: requestedURL!, resolvingAgainstBaseURL: false)
        let pageValue = components?.queryItems?.first(where: { $0.name == "page" })?.value
        XCTAssertEqual(pageValue, "3")
    }

    func test_whenGetCharacters_succeeds_shouldReturnDecodedModel() async throws {
        let data = makeValidResponseData()
        let response = HTTPURLResponse(url: baseEndpoint!, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.startIntercepting(with: .init(data: data, response: response, error: nil, requestObserver: nil))

        let sut = APIClient(session: session)
        let result = try await sut.getCharacters(page: 1)

        XCTAssertEqual(result.results.count, 1)
    }

    func test_whenGetCharacters_sessionReturnsError_shouldThrow() async {
        URLProtocolStub.startIntercepting(with: .init(data: nil, response: nil, error: TestError.any, requestObserver: nil))

        let sut = APIClient(session: session, maxRetries: 1, retryDelay: 0)

        do {
            _ = try await sut.getCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func test_whenGetCharacters_receivesInvalidData_shouldThrow() async {
        let response = HTTPURLResponse(url: baseEndpoint!, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.startIntercepting(with: .init(data: Data("invalid".utf8), response: response, error: nil, requestObserver: nil))

        let sut = APIClient(session: session, maxRetries: 1, retryDelay: 0)

        do {
            _ = try await sut.getCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(true)
        }
    }

    // MARK: - Retry

    func test_whenGetCharacters_failsOnFirstAttempt_shouldRetryAndSucceed() async throws {
        let successData = makeValidResponseData()
        let successResponse = HTTPURLResponse(url: baseEndpoint!, statusCode: 200, httpVersion: nil, headerFields: nil)

        URLProtocolStub.startIntercepting(withSequence: [
            .init(data: nil, response: nil, error: URLError(.networkConnectionLost), requestObserver: nil),
            .init(data: successData, response: successResponse, error: nil, requestObserver: nil)
        ])

        let sut = APIClient(session: session, maxRetries: 2, retryDelay: 0)
        let result = try await sut.getCharacters(page: 1)

        XCTAssertEqual(result.results.count, 1)
    }

    func test_whenGetCharacters_failsAllAttempts_shouldThrowLastError() async {
        var requestCount = 0
        URLProtocolStub.startIntercepting(withSequence: [
            .init(data: nil, response: nil, error: URLError(.networkConnectionLost), requestObserver: { _ in requestCount += 1 }),
            .init(data: nil, response: nil, error: URLError(.networkConnectionLost), requestObserver: { _ in requestCount += 1 }),
            .init(data: nil, response: nil, error: URLError(.networkConnectionLost), requestObserver: { _ in requestCount += 1 })
        ])

        let sut = APIClient(session: session, maxRetries: 3, retryDelay: 0)

        do {
            _ = try await sut.getCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(requestCount, 3)
        }
    }

    func test_whenGetCharacters_succeedsOnFirstAttempt_shouldNotRetry() async throws {
        var requestCount = 0
        let successData = makeValidResponseData()
        let successResponse = HTTPURLResponse(url: baseEndpoint!, statusCode: 200, httpVersion: nil, headerFields: nil)

        URLProtocolStub.startIntercepting(withSequence: [
            .init(data: successData, response: successResponse, error: nil, requestObserver: { _ in requestCount += 1 })
        ])

        let sut = APIClient(session: session, maxRetries: 3, retryDelay: 0)
        _ = try await sut.getCharacters(page: 1)

        XCTAssertEqual(requestCount, 1)
    }

    private func makeValidResponseData() -> Data {
        let json = """
        {
            "info": {
                "count": 1,
                "pages": 1,
                "next": null,
                "prev": null
            },
            "results": [
                {
                    "id": 1,
                    "name": "Rick Sanchez",
                    "status": "Alive",
                    "species": "Human",
                    "type": "",
                    "gender": "Male",
                    "origin": {
                        "name": "Earth",
                        "url": "https://example.com/origin/1"
                    },
                    "location": {
                        "name": "Earth",
                        "url": "https://example.com/location/1"
                    },
                    "image": "https://example.com/character/1.png",
                    "episode": [
                        "https://example.com/episode/1"
                    ],
                    "url": "https://example.com/character/1",
                    "created": "2020-01-01T00:00:00.000Z"
                }
            ]
        }
        """
        return Data(json.utf8)
    }
}
