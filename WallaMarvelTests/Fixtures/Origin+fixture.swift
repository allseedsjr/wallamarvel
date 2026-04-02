@testable import WallaMarvel

extension Origin {
    static func fixture(
        name: String = "Earth",
        url: String = "https://example.com/origin/earth"
    ) -> Self {
        Origin(name: name, url: url)
    }
}
