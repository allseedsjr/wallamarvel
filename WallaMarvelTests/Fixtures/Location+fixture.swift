@testable import WallaMarvel

extension Location {
    static func fixture(
        name: String = "Earth",
        url: String = "https://example.com/location/earth"
    ) -> Self {
        Location(name: name, url: url)
    }
}
