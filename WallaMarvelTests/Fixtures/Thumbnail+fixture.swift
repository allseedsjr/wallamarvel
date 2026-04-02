@testable import WallaMarvel

extension Thumbnail {
    static func fixture(
        path: String = "https://example.com/thumbnail",
        `extension`: String = "jpg"
    ) -> Self {
        Thumbnail(path: path, extension: `extension`)
    }
}
