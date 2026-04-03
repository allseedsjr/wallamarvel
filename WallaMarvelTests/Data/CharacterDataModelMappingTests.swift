import XCTest
@testable import WallaMarvel

final class CharacterDataModelMappingTests: XCTestCase {
    
    func test_characterDataModel_toDomain_shouldMapAllFields() throws {
        let dto = CharacterDataModel.fixture(
            id: 42,
            name: "Morty Smith",
            status: "Alive",
            species: "Human",
            gender: "Male",
            origin: Origin.fixture(name: "Earth C-137"),
            location: Location.fixture(name: "Dimension C-500"), image: "https://example.com/morty.png",
            episode: ["1", "2", "3"]
        )
        
        let domain = try dto.toDomain()
        
        XCTAssertEqual(domain.id, 42)
        XCTAssertEqual(domain.name, "Morty Smith")
        XCTAssertEqual(domain.status, "Alive")
        XCTAssertEqual(domain.species, "Human")
        XCTAssertEqual(domain.gender, "Male")
        XCTAssertEqual(domain.imageURL, "https://example.com/morty.png")
        XCTAssertEqual(domain.originName, "Earth C-137")
        XCTAssertEqual(domain.locationName, "Dimension C-500")
        XCTAssertEqual(domain.episodeCount, 3)
    }
    
    func test_characterDataModel_toDomain_withInvalidImageURL_shouldThrow() throws {
        let dto = CharacterDataModel.fixture(image: "not-a-valid-url")
        
        XCTAssertThrowsError(try dto.toDomain()) { error in
            XCTAssertEqual(error as? CharacterMappingError, .invalidImageURL)
        }
    }
    
    func test_characterDataModel_toDomain_withEmptyImageURL_shouldThrow() throws {
        let dto = CharacterDataModel.fixture(image: "")
        
        XCTAssertThrowsError(try dto.toDomain()) { error in
            XCTAssertEqual(error as? CharacterMappingError, .invalidImageURL)
        }
    }
    
    func test_characterDataContainer_toDomainCharacters_shouldMapAllCharacters() throws {
        let container = CharacterDataContainer.fixture(
            results: [
                CharacterDataModel.fixture(id: 1, name: "Rick"),
                CharacterDataModel.fixture(id: 2, name: "Morty")
            ]
        )
        
        let domains = try container.toDomainCharacters()
        
        XCTAssertEqual(domains.count, 2)
        XCTAssertEqual(domains[0].id, 1)
        XCTAssertEqual(domains[0].name, "Rick")
        XCTAssertEqual(domains[1].id, 2)
        XCTAssertEqual(domains[1].name, "Morty")
    }
    
    func test_characterDataContainer_toDomainCharacters_withInvalidCharacter_shouldThrow() throws {
        let container = CharacterDataContainer.fixture(
            results: [
                CharacterDataModel.fixture(id: 1, name: "Rick"),
                CharacterDataModel.fixture(id: 2, name: "InvalidCharacter", image: "")
            ]
        )
        
        XCTAssertThrowsError(try container.toDomainCharacters())
    }
}
