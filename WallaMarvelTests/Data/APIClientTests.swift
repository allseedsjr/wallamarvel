import XCTest
@testable import WallaMarvel

final class APIClientTests: XCTestCase {
    private let endpoint = URL(string: "https://rickandmortyapi.com/api/character")
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

    func test_whenGetHeroes_called_shouldRequestCorrectURL() async throws {
        var requestedURL: URL?
        let data = makeValidResponseData()
        let response = HTTPURLResponse(url: endpoint!, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.startIntercepting(with: .init(data: data, response: response, error: nil, requestObserver: { request in
            requestedURL = request.url
        }))

        let sut = APIClient(session: session)
        _ = try await sut.getCharacters()

        XCTAssertEqual(requestedURL, endpoint)
    }

    func test_whenGetHeroes_succeeds_shouldReturnDecodedModel() async throws {
        let data = makeValidResponseData()
        let response = HTTPURLResponse(url: endpoint!, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.startIntercepting(with: .init(data: data, response: response, error: nil, requestObserver: nil))

        let sut = APIClient(session: session)
        let result = try await sut.getCharacters()

        XCTAssertEqual(result.results.count, 1)
    }

    func test_whenGetHeroes_sessionReturnsError_shouldThrow() async {
        URLProtocolStub.startIntercepting(with: .init(data: nil, response: nil, error: TestError.any, requestObserver: nil))

        let sut = APIClient(session: session)

        do {
            _ = try await sut.getCharacters()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func test_whenGetHeroes_receivesInvalidData_shouldThrow() async {
        let response = HTTPURLResponse(url: endpoint!, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.startIntercepting(with: .init(data: Data("invalid".utf8), response: response, error: nil, requestObserver: nil))

        let sut = APIClient(session: session)

        do {
            _ = try await sut.getCharacters()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(true)
        }
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
