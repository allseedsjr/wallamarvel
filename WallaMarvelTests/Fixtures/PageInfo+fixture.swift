@testable import WallaMarvel

extension PageInfo {
    static func fixture(
        count: Int = 0,
        pages: Int = 0,
        next: String? = nil,
        prev: String? = nil
    ) -> Self {
        PageInfo(count: count, pages: pages, next: next, prev: prev)
    }
}
