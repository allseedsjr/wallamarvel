import Foundation

struct PageInfo: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
