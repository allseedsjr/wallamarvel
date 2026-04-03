import XCTest
@testable import WallaMarvel

final class GetCharactersRequestTests: XCTestCase {

    func test_makeURL_shouldHaveCorrectHostAndPath() throws {
        let sut = GetCharactersRequest(page: 1)
        let url = try sut.makeURL()

        XCTAssertEqual(url.host, "rickandmortyapi.com")
        XCTAssertEqual(url.path, "/api/character")
    }

    func test_makeURL_shouldUseHTTPS() throws {
        let sut = GetCharactersRequest(page: 1)
        let url = try sut.makeURL()

        XCTAssertEqual(url.scheme, "https")
    }

    func test_makeURL_shouldIncludePageQueryParameter() throws {
        let sut = GetCharactersRequest(page: 3)
        let url = try sut.makeURL()

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let pageValue = components?.queryItems?.first(where: { $0.name == "page" })?.value
        XCTAssertEqual(pageValue, "3")
    }

    func test_makeURL_differentPages_shouldProduceDifferentURLs() throws {
        let url1 = try GetCharactersRequest(page: 1).makeURL()
        let url2 = try GetCharactersRequest(page: 2).makeURL()

        XCTAssertNotEqual(url1, url2)
    }
}
